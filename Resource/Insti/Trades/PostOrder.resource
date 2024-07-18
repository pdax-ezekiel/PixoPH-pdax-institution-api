*** Settings ***
Documentation       [API Testing] PDAX Insti : Post Order
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

Post Order
    [Arguments]    ${row_index}   ${column_index}   ${param_count}

    Firm Quotes    ${row_index}   ${column_index}   ${param_count} 
    ${idempotency_id}=    Evaluate    str(uuid.uuid4())    modules=uuid
    ${post_order_payload}=    Set To Dictionary    ${post_order_payload}    quote_id=${firm_quotes_response}[quote_id]
    ${post_order_payload}=    Set To Dictionary    ${post_order_payload}    idempotency_id=${idempotency_id}
    ${post_order_payload}=    Set To Dictionary    ${post_order_payload}    side=${parameter_dictionary}[side]

     

    ${response}=     Post On Session    eisodos_login    ${endpoint_post_order}    headers=${login_param}  json=${post_order_payload}    expected_status=${parameter_dictionary}[status_code]
    ${json}=            Set Variable    ${response.json()}

    IF    "${parameter_dictionary}[expected_error]"=="no error"
        # Get the details value

        # Store to Post Order response dictionary
        ${post_order_response}=    set to dictionary  ${post_order_response}     order_id=${json}[data][order_id]
        ${post_order_response}=    set to dictionary  ${post_order_response}     status=${json}[data][status]
        ${post_order_response}=    set to dictionary  ${post_order_response}     quote_currency=${json}[data][quote_currency]
        ${post_order_response}=    set to dictionary  ${post_order_response}     base_currency=${json}[data][base_currency]
        ${post_order_response}=    set to dictionary  ${post_order_response}     side=${json}[data][side]
        ${post_order_response}=    set to dictionary  ${post_order_response}     base_quantity=${json}[data][base_quantity]
        ${post_order_response}=    set to dictionary  ${post_order_response}     price=${json}[data][price]
        ${post_order_response}=    set to dictionary  ${post_order_response}     total_amount=${json}[data][total_amount]
    END
    # [Return]    ${json}

Validate Post Order Response Parameters
    [Arguments]    ${row_index}   ${column_index}   ${param_count}
    Post Order     ${row_index}   ${column_index}   ${param_count}

    Run Keyword And Continue On Failure    Should Be Equal As Strings
    ...    ${post_order_response}[base_currency]    ${parameter_dictionary}[base_currency]

    Run Keyword And Continue On Failure    Should Be Equal As Strings
    ...    ${post_order_response}[quote_currency]    ${parameter_dictionary}[quote_currency]

    Run Keyword And Continue On Failure    Should Be Equal As Strings
    ...    ${post_order_response}[side]    ${parameter_dictionary}[side]

    Run Keyword And Continue On Failure    Should Be Equal As Strings
    ...    ${post_order_response}[status]    successful


    IF  "${parameter_dictionary}[currency]"=="PHP"

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${post_order_response}[total_amount]    ${parameter_dictionary}[quantity]

        ${decimal_count}=    Count Decimal    ${post_order_response}[base_quantity]

        ${expected_base_quantity}=    Evaluate    ${parameter_dictionary}[quantity]/${post_order_response}[price]

        ${expected_base_quantity}=    Truncate    ${expected_base_quantity}    ${decimal_count}

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${post_order_response}[base_quantity]    ${expected_base_quantity}
    ELSE
        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${post_order_response}[base_quantity]    ${parameter_dictionary}[quantity]

        ${expected_total_amount}=    Evaluate    ${parameter_dictionary}[quantity]*${post_order_response}[price]
        
        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${post_order_response}[total_amount]    ${expected_total_amount}

    END


    
Validate balance credit/debit
    [Arguments]    ${row_index}   ${column_index}   ${param_count}

    Eisodos Login    ${csv_path}    ${row_index}   ${column_index}   ${param_count}
    ${settle_curr_bal_before}=     Get User Balance    ${parameter_dictionary}[base_currency]
    ${traded_curr_bal_before}=     Get User Balance    ${parameter_dictionary}[quote_currency]

    Log    ${settle_curr_bal_before}
    Log    ${traded_curr_bal_before}

    Post Order    ${row_index}   ${column_index}   ${param_count}   
        
    ${settle_curr_bal_after}=     Get User Balance    ${parameter_dictionary}[base_currency]
    ${traded_curr_bal_after}=     Get User Balance    ${parameter_dictionary}[quote_currency]

    Log    ${settle_curr_bal_before}
    Log    ${traded_curr_bal_before}

    IF  "${parameter_dictionary}[side]" == "buy"
        ${expected_avail_settle}=    Evaluate    ${settle_curr_bal_before}[available]-${post_order_response}[total_amount]
        ${expected_total_settle}=    Evaluate    ${settle_curr_bal_before}[total]-${post_order_response}[total_amount]
        ${expected_avail_traded}=    Evaluate    ${traded_curr_bal_before}[available]+${post_order_response}[base_quantity]
        ${expected_total_traded}=    Evaluate    ${traded_curr_bal_before}[total]+${post_order_response}[base_quantity]


        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${expected_avail_settle}    ${settle_curr_bal_after}[available]

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${expected_total_settle}    ${settle_curr_bal_after}[total]

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${settle_curr_bal_before}[hold]    ${settle_curr_bal_after}[hold]

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${expected_avail_traded}    ${traded_curr_bal_after}[available]    

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${expected_total_traded}    ${traded_curr_bal_after}[total] 

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${traded_curr_bal_before}[hold]    ${traded_curr_bal_after}[hold]
    ELSE 
        ${expected_avail_settle}=    Evaluate    ${settle_curr_bal_before}[available]+${post_order_response}[total_amount]
        ${expected_total_settle}=    Evaluate    ${settle_curr_bal_before}[total]+${post_order_response}[total_amount]
        ${expected_avail_traded}=    Evaluate    ${traded_curr_bal_before}[available]-${post_order_response}[base_quantity]
        ${expected_total_traded}=    Evaluate    ${traded_curr_bal_before}[total]-${post_order_response}[base_quantity]


        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${expected_avail_settle}    ${settle_curr_bal_after}[available]

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${expected_total_settle}    ${settle_curr_bal_after}[total]

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${settle_curr_bal_before}[hold]    ${settle_curr_bal_after}[hold]

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${expected_avail_traded}    ${traded_curr_bal_after}[available]    

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
        ...    ${expected_total_traded}    ${traded_curr_bal_after}[total] 

        Run Keyword And Continue On Failure    Should Be Equal As Numbers    
         ...    ${traded_curr_bal_before}[hold]    ${traded_curr_bal_after}[hold] 
    END



*** Variables ***
# Base URL for testing
${endpoint_post_order}              v1/trade
${endpoint_firm_quotes}             v2/trade/quote



# CSV File Path
${csv_path}                 ./Data/Trades/PostOrder.csv

#Data Dictionary
&{post_order_payload}
&{post_order_response}
&{firm_quotes_response}