*** Settings ***
Documentation       [API Testing] PDAX Insti : Firm Quotes
Library             Collections
Library             RequestsLibrary
Library             JSONLibrary
Library             String
Library             SeleniumLibrary
Library             psycopg2
Resource            ../../Common/Login.resource

*** Keywords ***
Firm Quotes
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

    ${firm_quotes_request}=    Copy Dictionary    ${parameter_dictionary}
    Remove From Dictionary    ${firm_quotes_request}    environment    username    password    status_code    expected_error    user_id  
    ${quantity}=    Convert To Number    ${firm_quotes_request}[quantity]
    ${firm_quotes_request}=    Set To Dictionary    ${firm_quotes_request}    quantity=${quantity}
    ${response}=     Post On Session    eisodos_login    ${endpoint_firm_quotes}    headers=${login_param}  json=${firm_quotes_request}    expected_status=${parameter_dictionary}[status_code]
    ${json}=            Set Variable    ${response.json()}

    

    IF    "${parameter_dictionary}[expected_error]"=="no error"
        # Get the details value

        # Store to Firm Quotes response dictionary
        ${firm_quotes_response}=    set to dictionary  ${firm_quotes_response}     quote_id=${json}[data][quote_id]
        ${firm_quotes_response}=    set to dictionary  ${firm_quotes_response}     base_currency=${json}[data][base_currency]
        ${firm_quotes_response}=    set to dictionary  ${firm_quotes_response}     quote_currency=${json}[data][quote_currency]
        ${firm_quotes_response}=    set to dictionary  ${firm_quotes_response}     side=${json}[data][side]
        ${firm_quotes_response}=    set to dictionary  ${firm_quotes_response}     base_quantity=${json}[data][base_quantity]
        ${firm_quotes_response}=    set to dictionary  ${firm_quotes_response}     price=${json}[data][price]
        ${firm_quotes_response}=    set to dictionary  ${firm_quotes_response}     total_amount=${json}[data][total_amount]
    END
    # [Return]    ${json}

Validate Firm Quotes Response Parameters
    [Arguments]    ${row_index}   ${column_index}   ${param_count}
    Firm Quotes     ${row_index}   ${column_index}   ${param_count}

    Run Keyword And Continue On Failure    Should Be Equal As Strings
    ...    ${firm_quotes_response}[base_currency]    ${parameter_dictionary}[base_currency]

    Run Keyword And Continue On Failure    Should Be Equal As Strings
    ...    ${firm_quotes_response}[quote_currency]    ${parameter_dictionary}[quote_currency]

    Run Keyword And Continue On Failure    Should Be Equal As Strings
    ...    ${firm_quotes_response}[side]    ${parameter_dictionary}[side]

    Run Keyword And Continue On Failure    Should Not Be Empty    ${firm_quotes_response}[quote_id]


    IF  "${parameter_dictionary}[currency]"=="PHP"

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${firm_quotes_response}[total_amount]    ${parameter_dictionary}[quantity]

        ${decimal_count}=    Count Decimal    ${firm_quotes_response}[base_quantity]

        ${expected_base_quantity}=    Evaluate    ${parameter_dictionary}[quantity]/${firm_quotes_response}[price]

        ${expected_base_quantity}=    Truncate    ${expected_base_quantity}    ${decimal_count}

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${firm_quotes_response}[base_quantity]    ${expected_base_quantity}
    ELSE
        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${firm_quotes_response}[base_quantity]    ${parameter_dictionary}[quantity]

        ${expected_total_amount}=    Evaluate    ${parameter_dictionary}[quantity]*${firm_quotes_response}[price]

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${firm_quotes_response}[total_amount]    ${expected_total_amount}
    END

        

        

    



Authorize Firm Quotes
    [Arguments]    ${url}    ${username}    ${password}    
    Set Selenium Speed    0.1
    Open Browser   ${url}    chrome 
    Maximize Browser Window
    Sleep    2s
    # Click authorize payment button
    Click Button    //*[@id="root"]/div/div/div[2]/div[2]/div/button[1]
    Wait Until Element Is Visible    //*[@id="root"]/div[2]/div/div/div[3]/form/div[1]/div/div[1]/input    20
    # Input username and password 
    Input Text    //*[@id="root"]/div[2]/div/div/div[3]/form/div[1]/div/div[1]/input    ${username}
    Input Text    //*[@id="root"]/div[2]/div/div/div[3]/form/div[1]/div/div[2]/input    ${password}
    # Click Login
    Click Button    //*[@id="root"]/div[2]/div/div/div[3]/form/button
    Wait Until Element Is Visible    //*[@id="wiz-iframe-intent"]    20
    Select Frame    //*[@id="wiz-iframe-intent"]
    # Click Close of pop up window
    Run Keyword And Continue On Failure    Click Element    //*[@id="contentDiv"]/div/div/span
    Unselect Frame
    Wait Until Element Is Visible    //*[@id="root"]/div[2]/div[1]/div[1]/div[2]/div[2]/div/div[2]/button    20
    # Click go back to home
    Click Button    //*[@id="root"]/div[2]/div[1]/div[1]/div[2]/div[2]/div/div[2]/button
    



    
Validate balance crediting
    [Arguments]    ${row_index}   ${column_index}   ${param_count}
    Eisodos Login    ${csv_path}    ${row_index}   ${column_index}   ${param_count}
    ${settle_curr_bal_before}=     Get User Balance    PHP
    Log    ${settle_curr_bal_before}
    Firm Quotes    ${row_index}   ${column_index}   ${param_count}   
    
    Get Specific Fiat Transactions    ${firm_quotes_response}[identifier]
    Log    ${get_fiat_txn_dict}
    
    WHILE  "${get_fiat_txn_dict}[status]"!="COMPLETED"
        Sleep    1s
        Get Specific Fiat Transactions    ${firm_quotes_response}[identifier]
    END
        
    ${settle_curr_bal_after}=     Get User Balance    PHP
    ${expected_avail_after}=    Evaluate    ${settle_curr_bal_before}[available]+${parameter_dictionary}[amount]
    ${expected_total_after}=    Evaluate    ${settle_curr_bal_before}[total]+${parameter_dictionary}[amount]
    ${expected_hold_after}=    Set Variable    ${settle_curr_bal_before}[hold]

    Run Keyword And Continue On Failure    Should Be Equal As Numbers    ${expected_avail_after}    ${settle_curr_bal_after}[available]
    Run Keyword And Continue On Failure    Should Be Equal As Numbers    ${expected_total_after}    ${settle_curr_bal_after}[total]
    Run Keyword And Continue On Failure    Should Be Equal As Numbers    ${expected_hold_after}    ${settle_curr_bal_after}[hold]

*** Variables ***
# Base URL for testing
${endpoint_firm_quotes}              v2/trade/quote



# CSV File Path
${csv_path}                 ./Data/Trades/FirmQuotes.csv

#Data Dictionary
&{login_param}
&{firm_quotes_response}