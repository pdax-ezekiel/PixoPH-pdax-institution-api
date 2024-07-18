*** Settings ***
Documentation       [API Testing] PDAX Insti : Crypto-out
Library             Collections
Library             RequestsLibrary
Library             JSONLibrary
Library             String
Library             PostGRESQL
Library             psycopg2
Resource            ../../Common/Login.resource

*** Keywords ***
Crypto Out
    [Arguments]    ${row_index}   ${column_index}   ${param_count}

    # User logs in using cognito authentication to get the bearer token for non stellar end points
    # During cognito login parameters are get in CSV and stored in the &{parameter_dictionary}
    Eisodos Login    ${csv_path}    ${row_index}    ${column_index}    ${param_count}

        

    # Verify if sessions exists
    ${session_exists} =     Session Exists    eisodos_login
    # If Session does not exist, create eisodos_login Session
    IF    ${session_exists} == False
        Create Session      eisodos_login    ${base_url_dictionary}[base_url]
    END
        
    ${identifier}=    Evaluate    str(uuid.uuid4())    modules=uuid
    ${parameter_dictionary}=    set to dictionary  ${parameter_dictionary}     identifier=${identifier}
    ${status_code}=    Set Variable    ${parameter_dictionary}[status_code]
    ${expected_error}=    Set Variable    ${parameter_dictionary}[expected_error]
    ${crypto_out_request}=    Copy Dictionary    ${parameter_dictionary}
    Remove From Dictionary    ${crypto_out_request}    environment    username    password    status_code    expected_error    user_email    user_id
    Log    ${crypto_out_request}


    ${response}=     Post On Session    eisodos_login    ${endpoint_Crypto_out}    headers=${login_param}  json=${crypto_out_request}    expected_status=${status_code}
    ${json}=            Set Variable    ${response.json()}

    IF    "${expected_error}"=="no error"
       # Get the details value
        ${crypto_out_response}=    set to dictionary  ${crypto_out_response}     identifier=${json}[identifier]
        ${crypto_out_response}=    set to dictionary  ${crypto_out_response}     transaction_id=${json}[transaction_id]
        ${crypto_out_response}=    set to dictionary  ${crypto_out_response}     amount=${json}[amount]
        ${crypto_out_response}=    set to dictionary  ${crypto_out_response}     address=${json}[address]
        ${crypto_out_response}=    set to dictionary  ${crypto_out_response}     tag=${json}[tag]
        ${crypto_out_response}=    set to dictionary  ${crypto_out_response}     total=${json}[total]
        ${crypto_out_response}=    set to dictionary  ${crypto_out_response}     fee=${json}[fee]
        ${crypto_out_response}=    set to dictionary  ${crypto_out_response}     currency=${json}[currency]
        ${crypto_out_response}=    set to dictionary  ${crypto_out_response}     status=${json}[status]
    END

    Log    ${crypto_out_response}

    [Return]    ${json}

Verify Response Parameter
    [Arguments]    ${row_index}   ${column_index}   ${param_count}
    Crypto Out    ${row_index}   ${column_index}   ${param_count}
    Log    ${crypto_out_request}

    Should Be Equal As Strings     ${crypto_out_response}[identifier]    ${parameter_dictionary}[identifier]
    ${expected_amount}=    Evaluate        ${parameter_dictionary}[amount]-${crypto_out_response}[fee]
    Should Be Equal As Numbers     ${crypto_out_response}[amount]    ${expected_amount}
    Should Be Equal As Strings     ${crypto_out_response}[address]    ${parameter_dictionary}[address]
    Should Be Equal As Strings     ${crypto_out_response}[tag]    ${parameter_dictionary}[tag]
    Should Be Equal As Numbers     ${crypto_out_response}[total]    ${parameter_dictionary}[amount]
    Should Be Equal As Strings     ${crypto_out_response}[currency]    ${parameter_dictionary}[currency]

Verify Required Parameters
    [Arguments]    ${row_index}   ${column_index}   ${param_count}
    ${json}=    Crypto Out    ${row_index}   ${column_index}   ${param_count}

    Should Be Equal As Strings    ${json}[message]    ${parameter_dictionary}[expected_error]

Verify debiting
    [Arguments]    ${row_index}   ${column_index}   ${param_count}
    Eisodos Login    ${csv_path}    ${row_index}   ${column_index}   ${param_count}
    Sleep    10s
    ${settle_curr_bal_before}=     Get User Balance    ${parameter_dictionary}[currency]
    Crypto Out    ${row_index}   ${column_index}   ${param_count}  
    FOR    ${i}    IN RANGE    60
        Sleep   1s
        Get Specific Crypto Transactions    ${crypto_out_response}[identifier] 
        Exit For Loop If    "${get_crypto_txn}[status]"=="completed"
    END
    IF  "${get_crypto_txn}[status]"=="failed"
        ${settle_curr_bal_after}=     Get User Balance    ${parameter_dictionary}[currency]
        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${settle_curr_bal_before}[available]    ${settle_curr_bal_after}[available]
        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${settle_curr_bal_before}[total]    ${settle_curr_bal_after}[total]
        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${settle_curr_bal_before}[hold]    ${settle_curr_bal_after}[hold]
    ELSE IF    "${get_crypto_txn}[status]"=="completed"
        ${settle_curr_bal_after}=     Get User Balance    ${parameter_dictionary}[currency]
        
        ${expected_avail_bal_after}=    Evaluate    ${settle_curr_bal_before}[available]-${get_crypto_txn}[debit_net_amount]
        ${expected_total_bal_after}=    Evaluate    ${settle_curr_bal_before}[total]-${get_crypto_txn}[debit_net_amount]
        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${expected_avail_bal_after}    ${settle_curr_bal_after}[available]
        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${expected_total_bal_after}    ${settle_curr_bal_after}[total]
        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${settle_curr_bal_before}[hold]    ${settle_curr_bal_after}[hold]
    ELSE
        ${settle_curr_bal_after}=     Get User Balance    ${parameter_dictionary}[currency]
        
        ${expected_avail_bal_after}=    Evaluate    ${settle_curr_bal_before}[available]-${get_crypto_txn}[debit_net_amount]
        ${expected_hold_bal_after}=    Evaluate    ${settle_curr_bal_before}[hold]+${get_crypto_txn}[debit_net_amount]
        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${expected_avail_bal_after}    ${settle_curr_bal_after}[available]
        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${expected_hold_bal_after}    ${settle_curr_bal_after}[hold]
        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${settle_curr_bal_before}[total]    ${settle_curr_bal_after}[total]
    END

*** Variables ***
# Base URL for testing
${endpoint_Crypto_out}              v1/crypto/withdraw



# CSV File Path
${csv_path}                 ./Data/Withdrawal/CryptoOut.csv


#Data Dictionary
&{login_param}
&{crypto_out_response}
&{crypto_out_request}