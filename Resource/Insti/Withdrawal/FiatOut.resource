*** Settings ***
Documentation       [API Testing] PDAX Insti : Fiat-out
Library             Collections
Library             RequestsLibrary
Library             JSONLibrary
Library             String
# Library             PostGRESQL
Library             psycopg2
Resource            ../../Common/Login.resource

*** Keywords ***
Fiat Out
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

    ${amount}=    Convert To Number    ${parameter_dictionary}[amount]
    ${parameter_dictionary}=    set to dictionary  ${parameter_dictionary}     identifier=${identifier}
    ${parameter_dictionary}=    set to dictionary  ${parameter_dictionary}     amount=${amount}
    ${fiat_out_payload}=    Copy Dictionary    ${parameter_dictionary}
    Log        ${parameter_dictionary}
    Remove From Dictionary    ${fiat_out_payload}    environment    username    password    status_code    expected_error    user_email
    Log        ${parameter_dictionary}
    Log    ${fiat_out_payload}

    

    ${response}=     Post On Session    eisodos_login    ${endpoint_fiat_out}    headers=${login_param}  json=${fiat_out_payload}    expected_status=${parameter_dictionary}[status_code]
    ${json}=            Set Variable    ${response.json()}

     Log    ${fiat_out_payload}

    IF    "${parameter_dictionary}[expected_error]"=="no error"
       # Get the details value
        ${identifier}=          Get Value From Json    ${json}        $..data.identifier
        ${reference_number}=    Get Value From Json    ${json}        $..data.reference_number
        ${amount}=              Get Value From Json    ${json}        $..data.amount
        ${method}=              Get Value From Json    ${json}        $..data.method
        ${fee}=                 Get Value From Json    ${json}        $..data.fee
        ${status}=              Get Value From Json    ${json}        $..data.status
        ${status_2}=            Get Value From Json    ${json}        $..status
        # ${channel}=             Get Value From Json    ${json}        $..data.channel
        # ${fee_type}=            Get Value From Json    ${json}        $..data.fee_type
        # ${payment_amount}=      Get Value From Json    ${json}        $..data.payment_amount
        # ${total_amount}=        Get Value From Json    ${json}        $..data.total_amount

        # Store to fiat out response dictionary
        ${fiat_out_response}=    set to dictionary  ${fiat_out_response}     identifier=${identifier[0]}
        ${fiat_out_response}=    set to dictionary  ${fiat_out_response}     reference_number=${reference_number}
        ${fiat_out_response}=    set to dictionary  ${fiat_out_response}     amount=${amount[0]}
        ${fiat_out_response}=    set to dictionary  ${fiat_out_response}     method=${method[0]}
        ${fiat_out_response}=    set to dictionary  ${fiat_out_response}     fee=${fee[0]}
        ${fiat_out_response}=    set to dictionary  ${fiat_out_response}     status=${status[0]}
        # ${fiat_out_response}=    set to dictionary  ${fiat_out_response}     channel=${channel[0]}
        # ${fiat_out_response}=    set to dictionary  ${fiat_out_response}     fee_type=${fee_type[0]}
        # ${fiat_out_response}=    set to dictionary  ${fiat_out_response}     payment_amount=${payment_amount[0]}
        # ${fiat_out_response}=    set to dictionary  ${fiat_out_response}     total_amount=${total_amount[0]}
    END

    Log    ${fiat_out_response}

    
    
    [Return]    ${json}

Validate Fiat Out Response Parameters
    [Arguments]    ${row_index}   ${column_index}   ${param_count}
    Fiat Out    ${row_index}   ${column_index}   ${param_count}    
    Get Specific Fiat Transactions    ${fiat_out_response}[identifier]
    # Store fiat fee config as dictionary    ${fee_config_path} 
    Get fiat fee config    ${parameter_dictionary}[user_id]
    Should Be Equal As Strings    ${parameter_dictionary}[identifier]    ${fiat_out_response}[identifier]
    Should Be Equal As Numbers    ${parameter_dictionary}[amount]    ${fiat_out_response}[amount]
    Should Be Equal As Strings    ${parameter_dictionary}[method]    ${fiat_out_response}[method]
    Should Be Equal As Strings    PENDING   ${fiat_out_response}[status]
    
    ${fee_type}=    Evaluate    "${parameter_dictionary}[fee_type]".lower()
    ${split_fee}=    Split String    ${fee_config}[${get_fiat_txn_dict}[used_method]_${fee_type}]    _
    
    ${bank_fee_type}=    Set Variable    ${split_fee}[3]
    IF    "${bank_fee_type}"=="percentage"
        ${bank_fee}=    Set Variable    ${split_fee}[2]
        ${bank_fee}=    Evaluate    (${bank_fee}/100)*${parameter_dictionary}[amount]
    ELSE
         ${bank_fee}=    Set Variable    ${split_fee}[2]
    END
    ${pdax_type}=    Set Variable    ${split_fee}[1]
    IF    "${pdax_type}"=="percentage"
        ${pdax_fee}=    Set Variable    ${split_fee}[0]
        ${pdax_fee}=    Evaluate    (${pdax_fee}/100)*${parameter_dictionary}[amount]
    ELSE
         ${pdax_fee}=    Set Variable    ${split_fee}[0]
    END
    
    ${expected_fee}=    Evaluate    float(${bank_fee})+float(${pdax_fee})

    Should Be Equal As Numbers    ${expected_fee}    ${fiat_out_response}[fee]
    
Validate balance debiting
    [Arguments]    ${row_index}   ${column_index}   ${param_count}
    Eisodos Login    ${csv_path}    ${row_index}   ${column_index}   ${param_count}
    Sleep    10s
    ${settle_curr_bal_before}=     Get User Balance    PHP
    Log    ${settle_curr_bal_before}
    Fiat Out    ${row_index}   ${column_index}   ${param_count}  
    FOR    ${i}    IN RANGE    60
        Sleep   1s
        Get Specific Fiat Transactions    ${fiat_out_response}[identifier] 
        Exit For Loop If    "${get_fiat_txn_dict}[status]"=="COMPLETED"
    END
    ${settle_curr_bal_after}=     Get User Balance    PHP

    Get fiat fee config    ${parameter_dictionary}[user_id]
    
    ${fee_type}=    Evaluate    "${parameter_dictionary}[fee_type]".lower()
    ${split_fee}=    Split String    ${fee_config}[${get_fiat_txn_dict}[used_method]_${fee_type}]    _
    
    ${bank_fee_type}=    Set Variable    ${split_fee}[3]
    IF    "${bank_fee_type}"=="percentage"
        ${bank_fee}=    Set Variable    ${split_fee}[2]
        ${bank_fee}=    Evaluate    (${bank_fee}/100)*${parameter_dictionary}[amount]
    ELSE
         ${bank_fee}=    Set Variable    ${split_fee}[2]
    END
    ${pdax_type}=    Set Variable    ${split_fee}[1]
    IF    "${pdax_type}"=="percentage"
        ${pdax_fee}=    Set Variable    ${split_fee}[0]
        ${pdax_fee}=    Evaluate    (${pdax_fee}/100)*${parameter_dictionary}[amount]
    ELSE
         ${pdax_fee}=    Set Variable    ${split_fee}[0]
    END
    
    ${expected_fee}=    Evaluate    float(${bank_fee})+float(${pdax_fee})

    Log    ${get_fiat_txn_dict}[status]

    IF  "${get_fiat_txn_dict}[status]"=="COMPLETED"
        IF    "${fee_type}"=="beneficiary"
            ${expected_avail_after}=    Evaluate    ${settle_curr_bal_before}[available]-${parameter_dictionary}[amount]
            ${expected_total_after}=    Evaluate    ${settle_curr_bal_before}[total]-${parameter_dictionary}[amount]
            ${expected_hold_after}=    Set Variable    ${settle_curr_bal_before}[hold]
        ELSE
            ${expected_avail_after}=    Evaluate    ${settle_curr_bal_before}[available]-(${parameter_dictionary}[amount]+${expected_fee})
            ${expected_total_after}=    Evaluate    ${settle_curr_bal_before}[total]-(${parameter_dictionary}[amount]+${expected_fee})
            ${expected_hold_after}=    Set Variable    ${settle_curr_bal_before}[hold]
        END  
    ELSE IF    "${get_fiat_txn_dict}[status]"=="IN-PROGRESS"
        IF    "${fee_type}"=="beneficiary"        
            ${expected_avail_after}=    Evaluate    ${settle_curr_bal_before}[available]-${parameter_dictionary}[amount]
            ${expected_total_after}=    Set Variable    ${settle_curr_bal_before}[total]
            ${expected_hold_after}=    Evaluate    ${settle_curr_bal_before}[hold]+${parameter_dictionary}[amount]
        ELSE
            ${expected_avail_after}=    Evaluate    ${settle_curr_bal_before}[available]-(${parameter_dictionary}[amount]+${expected_fee})
            ${expected_total_after}=    Set Variable    ${settle_curr_bal_before}[total]
            ${expected_hold_after}=    Evaluate    ${settle_curr_bal_before}[hold]+(${parameter_dictionary}[amount]+${expected_fee})
        END
    ELSE
        Log    "************* Transaction FAILED *****************"
    END

    Run Keyword And Continue On Failure    Should Be Equal As Numbers    ${expected_avail_after}    ${settle_curr_bal_after}[available]
    Run Keyword And Continue On Failure    Should Be Equal As Numbers    ${expected_total_after}    ${settle_curr_bal_after}[total]
    Run Keyword And Continue On Failure    Should Be Equal As Numbers    ${expected_hold_after}    ${settle_curr_bal_after}[hold]

    
    
Verifiy fiat out Logic sequence
    [Arguments]    ${row_index}   ${column_index}   ${param_count}
    Eisodos Login    ${csv_path}    ${row_index}   ${column_index}   ${param_count}

    @{channel_up}=    Create List    1184    1187    1188    1189    1316    1101
    FOR  ${channel_up}  IN  @{channel_up}
            Payment Channel Activate Deactivate    ${channel_up}    enabled
    END  

    IF  "${parameter_dictionary}[channel_down]"!="null" 
        ${channel_down}=    Split String    ${parameter_dictionary}[channel_down]    _
        FOR  ${channel_down}  IN  @{channel_down}
            Payment Channel Activate Deactivate    ${channel_down}    disabled
        END  
    END

    ${json}=    Fiat Out    ${row_index}   ${column_index}   ${param_count}
    IF    "${parameter_dictionary}[expected_error]"=="no error"
        Get Specific Fiat Transactions    ${fiat_out_response}[identifier]
    END

    IF  "${parameter_dictionary}[channel_down]"!="null" 
        ${channel_down}=    Split String    ${parameter_dictionary}[channel_down]    _
        FOR  ${channel_down}  IN  @{channel_down}
            IF    "${channel_down}"=="1184"
                ${parameter_dictionary}=    Set To Dictionary    ${parameter_dictionary}    ubp_partner_cashout=down
                Log    ${parameter_dictionary}[ubp_partner_cashout]
            ELSE IF    "${channel_down}"=="1187"
                ${parameter_dictionary}=    Set To Dictionary    ${parameter_dictionary}    instapay_emi_p2p_cashout=down
            ELSE IF    "${channel_down}"=="1188" or "${channel_down}"=="1101"
                ${parameter_dictionary}=    Set To Dictionary    ${parameter_dictionary}    InstaPay=down
            ELSE IF    "${channel_down}"=="1189"
                ${parameter_dictionary}=    Set To Dictionary    ${parameter_dictionary}    pesonet=down
            ELSE IF    "${channel_down}"=="1316"
                ${parameter_dictionary}=    Set To Dictionary    ${parameter_dictionary}    paymaya_wallet=down
            END
        END  
    END

    IF  "${parameter_dictionary}[ubp_partner_cashout]"=="supported" and ${parameter_dictionary}[amount]<=10000000
        Should Be Equal As Strings     ${get_fiat_txn_dict}[used_method]    ubp_partner_cashout
    ELSE IF  "${parameter_dictionary}[method]"=="PAY-TO-ACCOUNT-REAL-TIME" and ${parameter_dictionary}[amount]<=50000
        IF  "${parameter_dictionary}[paymaya_wallet]"=="supported" 
            Should Be Equal As Strings     ${get_fiat_txn_dict}[used_method]    paymaya_wallet
        ELSE IF    "${parameter_dictionary}[instapay_emi_p2p_cashout]"=="supported" 
            Should Be Equal As Strings     ${get_fiat_txn_dict}[used_method]    instapay_emi_p2p_cashout
        ELSE IF    "${parameter_dictionary}[InstaPay]"=="supported" 
            Should Be Equal As Strings     ${get_fiat_txn_dict}[used_method]    instapay
        ELSE
            Should Be Equal As Strings    ${json}[data][status]    FAILED
            Should Be Equal As Strings    ${json}[status]    failed
        END
    ELSE IF  "${parameter_dictionary}[method]"=="PAY-TO-ACCOUNT-REAL-TIME" and ${parameter_dictionary}[amount]>50000
        Should Be Equal As Strings    ${parameter_dictionary}[expected_error]    ${json}[message]
    ELSE IF    "${parameter_dictionary}[method]"=="PAY-TO-ACCOUNT-NON-REAL-TIME" and ${parameter_dictionary}[amount]<=50000
        IF    "${parameter_dictionary}[paymaya_wallet]"=="supported" 
            Should Be Equal As Strings     ${get_fiat_txn_dict}[used_method]    paymaya_wallet
        ELSE IF    "${parameter_dictionary}[instapay_emi_p2p_cashout]"=="supported"
            Should Be Equal As Strings     ${get_fiat_txn_dict}[used_method]    instapay_emi_p2p_cashout    
        ELSE IF    "${parameter_dictionary}[InstaPay]"=="supported"
            Should Be Equal As Strings     ${get_fiat_txn_dict}[used_method]    instapay   
        ELSE IF    "${parameter_dictionary}[pesonet]"=="supported"
            Should Be Equal As Strings     ${get_fiat_txn_dict}[used_method]    pesonet 
        ELSE
            Should Be Equal As Strings    ${json}[data][status]    FAILED
            Should Be Equal As Strings    ${json}[status]    failed
        END
    ELSE IF    "${parameter_dictionary}[method]"=="PAY-TO-ACCOUNT-NON-REAL-TIME" and ${parameter_dictionary}[amount]>50000 and ${parameter_dictionary}[amount]<=10000000 and "${parameter_dictionary}[pesonet]"=="supported"
        Should Be Equal As Strings     ${get_fiat_txn_dict}[used_method]    pesonet 
    ELSE IF    "${parameter_dictionary}[method]"=="PAY-TO-ACCOUNT-NON-REAL-TIME" and ${parameter_dictionary}[amount]>50000 and ${parameter_dictionary}[amount]<=10000000 and "${parameter_dictionary}[pesonet]"=="down" and "${parameter_dictionary}[ubp_partner_cashout]"=="down"
        Should Be Equal As Strings    ${json}[data][status]    FAILED
            Should Be Equal As Strings    ${json}[status]    failed
    ELSE
        Should Be Equal As Strings    ${json}[message]    ${parameter_dictionary}[expected_error]
    END    

    IF  "${parameter_dictionary}[channel_down]"!="null"
        ${channel_down}=    Split String    ${parameter_dictionary}[channel_down]    _
        FOR  ${channel_down}  IN  @{channel_down}
            Payment Channel Activate Deactivate    ${channel_down}    enabled
        END 
    END

*** Variables ***
# Base URL for testing
${endpoint_fiat_out}              v1/fiat/withdraw



# CSV File Path
${csv_path}                 ./Data/Withdrawal/FiatOut.csv
${fee_config_path}          ./Data/Config/FiatFeeConfig.csv

#Data Dictionary
&{login_param}
&{fiat_out_response}