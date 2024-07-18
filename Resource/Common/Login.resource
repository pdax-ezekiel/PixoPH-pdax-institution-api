*** Settings ***
Documentation       [API Testing] Stellar endpoint : crypto-out
Library             Collections
Library             RequestsLibrary
Library             String
Library             JSONLibrary
#Library             SeleniumLibrary
Resource            ./CommonTools.resource

*** Keywords ***
# Login a user using the /auth/login endpoint of Velo.,,                                                                                      nnbv;pyp ,
# PARAMETERS:
    # ${row_index}        = Row index in the CSV to specify the request paramaters
    # ${column_index}     = Column index in the CSV to specify the request paramaters
    # ${param_count}      = TOtal robcount of request paramaters
# RETURNS : Response Body in JSON format

Eisodos Login
    [Arguments]    ${csv_path}    ${row_index}   ${column_index}   ${param_count}

    #${login_param}=    Empty Dictionary    ${login_param}
    Get CSV for Specific Parameters    ${csv_path}         ${row_index}
    ...                                                 ${column_index}     ${param_count}

    # Setup Environment URL: &{base_url} will be defined here
    # using the environment from the ${parameter_dictionary}[environment]
    Set Up Environment    ${parameter_dictionary}[environment]

    ${login_param}=    Set To Dictionary    ${login_param}   username=${parameter_dictionary}[username]
    ${login_param}=    Set To Dictionary    ${login_param}   password=${parameter_dictionary}[password]

    # Verify if sessions exists
    ${session_exists} =     Session Exists    eisodos_login

    # If Session does not exist, create Stellar Session
    IF    ${session_exists} == False
        Create Session      eisodos_login    ${base_url_dictionary}[base_url]
    END

    # Eisodos Authentication and Status Code = 200
    ${response}=     Post On Session     eisodos_login   ${endpoint_login}    json=${login_param}    expected_status=200

    IF    ${response.status_code}==200
        # Get Response body to JSON
        ${json}=            Set Variable    ${response.json()}

        # Required Response Parameter
        ${email}=           Get Value From Json    ${json}        $..email
        ${username}=        Get Value From Json    ${json}        $..username
        ${access_token}=    Get Value From Json    ${json}        $..access_token
        ${id_token}=        Get Value From Json    ${json}        $..id_token
        ${refresh_token}=   Get Value From Json    ${json}        $..refresh_token

        ${parameter_dictionary}=    Set To Dictionary    ${parameter_dictionary}     user_id=${username[0]}

        ${login_param}=    Empty Dictionary     ${login_param}
        ${login_param}=    Set To Dictionary    ${login_param}     Authorization=Bearer ${id_token[0]}
        ${login_param}=    Set To Dictionary    ${login_param}     access_token=${access_token[0]}
        ${login_param}=    Set To Dictionary    ${login_param}     id_token=${id_token[0]}
    END

    IF     ${response.status_code} == 200    RETURN   ${json}


Eisodos Login Without Get Param
    [Arguments]    ${username}=admin@pdax.ph    ${password}=Pd@xAdm1nTest    ${is_backend}=true

    Empty Dictionary    ${login_param}
    ${login_param}=    Set To Dictionary    ${login_param}   username=${username}
    ${login_param}=    Set To Dictionary    ${login_param}   password=${password}
    ${login_param}=    Set To Dictionary    ${login_param}   is_backend=${is_backend}

    # Verify if sessions exists
    ${session_exists} =     Session Exists    eisodos_login_new

    # If Session does not exist, create Stellar Session
    IF    ${session_exists} == False
        Create Session      eisodos_login_new    https://api.sandbox.pdax.ph/auth
    END

    # Eisodos Authentication and Status Code = 200
    ${response}=     Post On Session     eisodos_login_new   ${admin_login}    json=${login_param}    expected_status=200

    IF    ${response.status_code}==200
        # Get Response body to JSON
        ${json}=            Set Variable    ${response.json()}

        # Required Response Parameter
        ${email}=           Get Value From Json    ${json}        $..email
        ${username}=        Get Value From Json    ${json}        $..username
        ${access_token}=    Get Value From Json    ${json}        $..access_token
        ${id_token}=        Get Value From Json    ${json}        $..id_token
        ${refresh_token}=   Get Value From Json    ${json}        $..refresh_token

        ${parameter_dictionary}=    Set To Dictionary    ${parameter_dictionary}     user_id=${username[0]}

        ${login_param}=    Empty Dictionary     ${login_param}
        ${login_param}=    Set To Dictionary    ${login_param}     Authorization=Bearer ${id_token[0]}
        ${login_param}=    Set To Dictionary    ${login_param}     access_token=${access_token[0]}
        ${login_param}=    Set To Dictionary    ${login_param}     id_token=${id_token[0]}
        ${login_param2}=    Set To Dictionary    ${login_param2}     Authorization=Bearer ${id_token[0]}
    END

    IF     ${response.status_code} == 200    RETURN   ${json}

*** Variables ***
${endpoint_login}                   v1/login
${admin_login}                      login
&{login_param}
&{login_param2}
