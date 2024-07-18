*** Settings ***
Documentation       [API Testing] PDAX Insti : Fiat-In
Library             Collections
Library             RequestsLibrary
Library             JSONLibrary
Library             String
Library             SeleniumLibrary
Library             psycopg2
Resource            ../../Common/Login.resource

*** Keywords ***
Fiat In
    [Arguments]    ${row_index}   ${column_index}   ${param_count}

    # User logs in using cognito authentication to get the bearer token for non stellar end points
    # During cognito login parameters are get in CSV and stored in the &{parameter_di`1231`    ctionary}
    Eisodos Login    ${csv_path}    ${row_index}    ${column_index}    ${param_count}

    # Verify if sessions exists
    ${session_exists} =     Session Exists    eisodos_login
    # If Session does not exist, create eisodos_login Session
    IF    ${session_exists} == False
        Create Session      eisodos_login    ${base_url_dictionary}[base_url]
    END

    FOR  ${x}  IN RANGE    ${parameter_dictionary}[loop]
        ${identifier}=    Evaluate    str(uuid.uuid4())    modules=uuid
        ${amount}=    Convert To Number    ${parameter_dictionary}[amount]
        ${parameter_dictionary}=    set to dictionary  ${parameter_dictionary}     identifier=${identifier}
        ${parameter_dictionary}=    set to dictionary  ${parameter_dictionary}     amount=${amount}
        ${fiat_In_payload}=    Copy Dictionary    ${parameter_dictionary}
        Log        ${parameter_dictionary}
        Remove From Dictionary    ${fiat_In_payload}    environment    username    password    status_code    expected_error    user_email    user_id    loop    authorize
        Log        ${parameter_dictionary}
        Log    ${fiat_In_payload}

        ${response}=     Post On Session    eisodos_login    ${endpoint_fiat_In}    headers=${login_param}  json=${fiat_In_payload}    expected_status=${parameter_dictionary}[status_code]
        ${json}=            Set Variable    ${response.json()}

        IF    "${parameter_dictionary}[expected_error]"=="no error"
        # Get the details value

            # Store to fiat In response dictionary
            ${fiat_In_response}=    set to dictionary  ${fiat_In_response}     identifier=${json}[identifier]
            ${fiat_In_response}=    set to dictionary  ${fiat_In_response}     reference_number=${json}[reference_number]
            ${fiat_In_response}=    set to dictionary  ${fiat_In_response}     amount=${json}[amount]
            ${fiat_In_response}=    set to dictionary  ${fiat_In_response}     method=${json}[method]
            ${fiat_In_response}=    set to dictionary  ${fiat_In_response}     payment_checkout_url=${json}[payment_checkout_url]
            ${fiat_In_response}=    set to dictionary  ${fiat_In_response}     fee=${json}[fee]
            ${fiat_In_response}=    set to dictionary  ${fiat_In_response}     status=${json}[status]
        END
        IF    "${parameter_dictionary}[authorize]"=="yes"
            Authorize Fiat In    ${fiat_In_response}[payment_checkout_url]    ${parameter_dictionary}[username]    ${parameter_dictionary}[password]   
        END 
        Log    ${x}
    END

    
    
    # [Return]    ${json}
Authorize Fiat In
    [Arguments]    ${url}    ${username}    ${password}    
    Set Selenium Speed    0.1
    Open Browser   ${url}    chrome 
    Maximize Browser Window
    Sleep    2s
    # Click authorize payment button
    Click Button    //*[@id="root"]/div/div/div[2]/div[2]/div/button[1]
    Element Should Be Visible
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
        # Unselect Frame
        # Wait Until Element Is Visible    //*[@id="root"]/div[2]/div[1]/div[1]/div[2]/div[2]/div/div[2]/button    20
        # # Click go back to home
        # Click Button    //*[@id="root"]/div[2]/div[1]/div[1]/div[2]/div[2]/div/div[2]/button
    


Validate Fiat In Response Parameters
    [Arguments]    ${row_index}   ${column_index}   ${param_count}
    Fiat In    ${row_index}   ${column_index}   ${param_count}    
    Get Specific Fiat Transactions    ${fiat_In_response}[identifier]
    Store fiat fee config as dictionary    ${fee_config_path}    fiat_in

    Should Be Equal As Strings    ${parameter_dictionary}[identifier]    ${fiat_In_response}[identifier]
    Should Be Equal As Numbers    ${parameter_dictionary}[amount]    ${fiat_In_response}[amount]
    Should Be Equal As Strings    ${parameter_dictionary}[method]    ${fiat_In_response}[method]
    Should Be Equal As Strings    PENDING   ${fiat_In_response}[status]
    Should Not Be Empty    ${fiat_In_response}[payment_checkout_url]
    Should Not Be Empty    ${fiat_In_response}[reference_number]
    ${split_fee}=    Split String    ${config_dictionary}[${parameter_dictionary}[user_id]_${parameter_dictionary}[method]]    _
    
    ${bank_fee_type}=    Set Variable    ${split_fee}[1]
    IF    "${bank_fee_type}"=="percentage"
        ${bank_fee}=    Set Variable    ${split_fee}[0]
        ${bank_fee}=    Evaluate    (${bank_fee}/100)*${parameter_dictionary}[amount]
    ELSE
         ${bank_fee}=    Set Variable    ${split_fee}[0]
    END
    ${pdax_type}=    Set Variable    ${split_fee}[3]
    IF    "${pdax_type}"=="percentage"
        ${pdax_fee}=    Set Variable    ${split_fee}[2]
        ${pdax_fee}=    Evaluate    (${pdax_fee}/100)*${parameter_dictionary}[amount]
    ELSE
         ${pdax_fee}=    Set Variable    ${split_fee}[2]
    END
    
    ${expected_fee}=    Evaluate    ${bank_fee}+${pdax_fee}

    Should Be Equal As Numbers    ${expected_fee}    ${fiat_In_response}[fee]
    
Validate balance crediting
    [Arguments]    ${row_index}   ${column_index}   ${param_count}
    Eisodos Login    ${csv_path}    ${row_index}   ${column_index}   ${param_count}
    ${settle_curr_bal_before}=     Get User Balance    PHP
    Log    ${settle_curr_bal_before}
    Fiat In    ${row_index}   ${column_index}   ${param_count}   
    
    Get Specific Fiat Transactions    ${fiat_In_response}[identifier]
    Log    ${get_fiat_txn_dict}
    
    WHILE  "${get_fiat_txn_dict}[status]"!="COMPLETED"
        Sleep    1s
        Get Specific Fiat Transactions    ${fiat_In_response}[identifier]
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
${endpoint_fiat_In}              /fiat/deposit



# CSV File Path
${csv_path}                 ./Data/deposit/FiatIn.csv
${fee_config_path}          ./Data/Config/FiatFeeConfig.csv

#Data Dictionary
&{login_param}
&{fiat_In_response}