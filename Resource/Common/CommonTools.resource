*** Settings ***
Documentation       [Common Methods]
Library             Collections
Library             RequestsLibrary
Library             JSONLibrary
Library             String
Library             ../py/csvlib.py
Resource            ./Login.resource




*** Keywords ***
# Get Request Parameters from specific Index of CSV
# PARAMETERS:
    # ${path}               = CSV Path that contains the Request Parameters
    # ${row_index}          = Row index of the CSV
    # ${param_count}        = Total count of Request Paramaters
# RETURNS : Specific Index from CSV which contains Request Paramaters for the endpoint
Get CSV for Specific Parameters
    [Arguments]    ${path}    ${row_index}   ${first_column_index}   ${param_count}
    # Get CSV to list
    Log    ${path}
    ${list}=		csvlib.read csv as list    ${path}
    Log    ${list}

    ${row_count}=    Get Length    ${list}
    ${row_count}=    Evaluate    ${row_count}-1
    Log    ${row_count}
    ${column_count}=    Get Length    ${list[0]}
    Log    ${column_count}

    # Get the last Column Index
    ${last_column_index}=    Evaluate    ${param_count}+${first_column_index}

    # Empty the dictionary
    ${parameter_dictionary}=    Empty Dictionary    ${parameter_dictionary}

    # Get values of all parameters in specific Row Index
    FOR    ${i}    IN RANGE    ${first_column_index}    ${last_column_index}
        # Get Key and Value
        ${parameter_dictionary}=    Set to Dictionary    ${parameter_dictionary}   ${list[0]}[${i}]=${list[${row_index}]}[${i}]
    END

    # Return the retrieved paramaters from CSV
    [Return]    ${parameter_dictionary}

Get fiat fee config
    [Arguments]    ${user_id}

    ${get_fee_config}=    Set Variable    ${get_fee_config}/${user_id}

    Eisodos Login Without Get Param

    ${response}=     Get On Session    eisodos_login    ${get_fee_config}        headers=${login_param}   expected_status=200
    ${json}=            Set Variable    ${response.json()}
    ${config_length}=    Get Length    ${json}[data]

    IF    ${config_length} != 0
        FOR    ${i}    IN RANGE   ${config_length} 
            ${fee_config}=    Set To Dictionary    ${fee_config}     ${json}[data][${i}][payment_channel]_${json}[data][${i}][fee_side]=${json}[data][${i}][pdax_fee]_${json}[data][${i}][pdax_fee_type]_${json}[data][${i}][bank_fee_amount]_${json}[data][${i}][bank_fee_type]
        END     
    END

    
    Log    ${fee_config}


Store fiat fee config as dictionary
#   stores the fee config in a dictionary by combining the username_paymentchannel_fee_type 
#   to create a unique key and the value will be the bank_fee_feeValueType_pdax_fee_feeValueType

    [Arguments]    ${path}    ${fiat_txn}=fiat_out      
    # Get CSV to list
    Log    ${path}
    ${list}=		csvlib.read csv as list    ${path}
    Log    ${list}

    ${row_count}=    Get Length    ${list}
    ${row_count}=    Evaluate    ${row_count}-1
    Log    ${row_count}
        

    # Empty the dictionary
    ${config_dictionary}=    Empty Dictionary    ${config_dictionary}
    IF    "${fiat_txn}"=="fiat_out"
        # Get values of all parameters in specific Row Index
        FOR    ${x}    IN RANGE    1    ${row_count}
            ${config_dictionary}=    Set to Dictionary    ${config_dictionary}   ${list[${x}]}[${1}]_${list[${x}]}[${2}]_${list[${x}]}[${7}]=${list[${x}]}[${3}]_${list[${x}]}[${4}]_${list[${x}]}[${5}]_${list[${x}]}[${6}]
        END
    ELSE
        FOR    ${x}    IN RANGE    1    ${row_count}
            ${config_dictionary}=    Set to Dictionary    ${config_dictionary}   ${list[${x}]}[${1}]_${list[${x}]}[${2}]=${list[${x}]}[${3}]_${list[${x}]}[${4}]_${list[${x}]}[${5}]_${list[${x}]}[${6}]
        END
    END
    Log    ${config_dictionary}
    
    
    

    # Return the retrieved config from CSV
    [Return]    ${config_dictionary}

Set Up Environment
    [Arguments]    ${environment}

     # Empty the dictionary
    ${base_url_dictionary}=    Empty Dictionary    ${base_url_dictionary}

    ${base_url_dictionary}=        Set To Dictionary  ${base_url_dictionary}    base_url=https://${environment}.services.sandbox.pdax.ph/api/pdax-api/pdax-institution/

    [Return]    ${base_url_dictionary}

Get Specific Fiat Transactions
    [Arguments]    ${identifier}=null    ${transaction_id}=null

    # Empty Dictionary    ${get_fiat_txn_dict}

    IF    "${identifier}"!="null"
        ${get_fiat_param}=    Set To Dictionary    ${get_fiat_param}    identifier=${identifier}
    ELSE
        ${get_fiat_param}=    Set To Dictionary    ${get_fiat_param}    reqId=${transaction_id}
    END 

    Log    ${get_fiat_param}

    ${response}=     Get On Session    eisodos_login    ${get_fiat_endpoint}    params=${get_fiat_param}    headers=${login_param}   expected_status=200
    ${json}=            Set Variable    ${response.json()}

    ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     identifier=${json}[data][0][identifier]
    ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     transaction_id=${json}[data][0][transaction_id]
    ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     amount=${json}[data][0][amount]
    ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     fee=${json}[data][0][fee]
    ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     method=${json}[data][0][method]
    ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     mode=${json}[data][0][mode]
    ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     reference_number=${json}[data][0][reference_number]
    ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     fulfilled_at=${json}[data][0][fulfilled_at]
    ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     rejection_reason=${json}[data][0][rejection_reason]
    ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     currency=${json}[data][0][currency]
    ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     status=${json}[data][0][status]
    Log    ${get_fiat_txn_dict}[status]
    ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     fee_type=${json}[data][0][fee_type]
    ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     retried_methods=${json}[data][0][retried_methods]
    
    ${length}=    Get Length    ${get_fiat_txn_dict}[retried_methods]
    IF    ${length} != 0
        ${length}=    Evaluate    ${length}-1
        ${get_fiat_txn_dict}=    Set To Dictionary    ${get_fiat_txn_dict}     used_method=${json}[data][0][retried_methods][${length}][channel]
    END
Get User Balance   
    [Arguments]    ${currency}
    Empty Dictionary    ${get_bal_param}
    ${get_bal_param}=    Set To Dictionary    ${get_bal_param}    currency=${currency}
    ${response}=     Get On Session    eisodos_login    ${get_bal_endpoint}    params=${get_bal_param}    headers=${login_param}   expected_status=200
    ${json}=            Set Variable    ${response.json()}
    [Return]    ${json}[data][0]
        

Empty Dictionary
    [Arguments]    ${dictionary}
    ${keys}=    Get Dictionary Keys    ${dictionary}
    ${length}=    Get length    ${keys}

    FOR    ${index}    IN RANGE    0    ${length}
        Remove From Dictionary    ${dictionary}    ${keys}[${index}]
    END

    [Return]    ${dictionary}
Payment Channel Activate Deactivate
    [Arguments]    ${channel_id}    ${status}=disabled
    # 7 - InstaPay
    # 138 - instapay_emi_p2p_cashout
    # 20 - ubp_partner_cashout 

    Eisodos Login Without Get Param

    ${body}=    Set To Dictionary    ${body}    id=${channel_id}
    ${body}=    Set To Dictionary    ${body}    status=${status}
    
    ${session_exists} =     Session Exists    payments_session

    IF    ${session_exists} == False
        Create Session      payments_session    https://api-stage.sandbox.pdax.ph
    END
    ${response}=     PATCH On Session   payments_session    /limits/v2/console-channel    headers=${login_param2}  json=${body} 

Get Specific Crypto Transactions
    [Arguments]    ${identifier}=null    

    ${get_crypto_param}=    Set To Dictionary    ${get_crypto_param}    identifier=${identifier}
    ${response}=     Get On Session    eisodos_login    ${get_crypto_endpoint}    params=${get_crypto_param}    headers=${login_param}   expected_status=200
    ${json}=            Set Variable    ${response.json()}

    ${get_crypto_txn}=    Set To Dictionary    ${get_crypto_txn}     identifier=${json}[data][0][identifier]
    ${get_crypto_txn}=    Set To Dictionary    ${get_crypto_txn}     debit_ccy=${json}[data][0][debit_ccy]
    ${get_crypto_txn}=    Set To Dictionary    ${get_crypto_txn}     debit_amount=${json}[data][0][debit_amount]
    ${get_crypto_txn}=    Set To Dictionary    ${get_crypto_txn}     debit_net_amount=${json}[data][0][debit_net_amount]
    ${get_crypto_txn}=    Set To Dictionary    ${get_crypto_txn}     fee_amount=${json}[data][0][fee_amount]
    ${get_crypto_txn}=    Set To Dictionary    ${get_crypto_txn}     status=${json}[data][0][status]
    ${get_crypto_txn}=    Set To Dictionary    ${get_crypto_txn}     txn_hash=${json}[data][0][txn_hash]
    ${get_crypto_txn}=    Set To Dictionary    ${get_crypto_txn}     transaction_id=${json}[data][0][transaction_id]
    ${get_crypto_txn}=    Set To Dictionary    ${get_crypto_txn}     receiver_wallet_address=${json}[data][0][receiver_wallet_address]
    ${get_crypto_txn}=    Set To Dictionary    ${get_crypto_txn}     receiver_wallet_address_tag=${json}[data][0][receiver_wallet_address_tag]

** Variables ***
# Empty Dictionary Initiations
&{base_url_dictionary}
&{parameter_dictionary}
&{config_dictionary}
&{fee_config}
&{get_fiat_txn_dict}
&{get_fiat_param}
&{get_bal_param} 
&{login}
&{body}
&{get_crypto_param}
&{get_crypto_txn}


# Empty Variable Initiations
${get_fiat_endpoint}        v1/fiat/transactions
${get_crypto_endpoint}        v1/crypto/transactions
${get_bal_endpoint}        v1/balances
${get_fee_config}            v1/fee-configurations/

