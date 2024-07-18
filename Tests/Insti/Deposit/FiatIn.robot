*** Settings ***
Documentation       [API Testing] PDAX Insti : Fiat In
...                 Run Code : robot -d Output -i FiatIn Tests/Insti/Deposit
Resource            /Users/EDCIsidro/PycharmProjects/PDAX-Insti/Resource/Insti/Deposit/FiatIn.resource

*** Variables ***
${column}  45
${column_offset}    2

*** Test Cases ***
# Checks for successful request and status code=200
TC1 : Fiat In : Successful Request : Status Code Check 200
    [Tags]      FiatIn:TC1     FiatIn
    ${response}=      Fiat In  1    ${column_offset}    ${column}
    Log  ${response} 

# Checks the response parameter
TC2 : Fiat In : Validate Fiat In Response Payload
    [Tags]      FiatIn:TC2     FiatIn
    ${response}=      Validate Fiat In Response Parameters  2    ${column_offset}    ${column}
    Log  ${response} 

# Checks crediting of the user's balance when fee type is Sender
TC3 : Fiat In : Validate Balance crediting 
    [Tags]      FiatIn:TC3     FiatIn
    ${response}=      Validate balance crediting  3    ${column_offset}    ${column}
    Log  ${response} 
