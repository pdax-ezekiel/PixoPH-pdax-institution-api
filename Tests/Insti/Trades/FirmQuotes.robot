*** Settings ***
Documentation       [API Testing] PDAX Insti : Firm Quotes
...                 Run Code : robot -d Output -i FirmQuotes Tests/Insti/Trades
Resource            /Users/EDCIsidro/PycharmProjects/PDAX-Insti/Resource/Insti/Trades/FirmQuotes.resource

*** Variables ***
${column}  10
${column_offset}    2

*** Test Cases ***
# Checks for successful request and status code=200
TC1 : Firm Quotes : Successful Request : Status Code Check 200
    [Tags]      FirmQuotes:TC1     FirmQuotes
    ${response}=      Firm Quotes  1    ${column_offset}    ${column}
    Log  ${response} 

# Checks the response parameter
TC2 : Firm Quotes : Validate Firm Quotes Response Payload : currency = PHP
    [Tags]      FirmQuotes:TC2     FirmQuotes
    ${response}=      Validate Firm Quotes Response Parameters  2    ${column_offset}    ${column}
    Log  ${response} 

# Checks the response parameter
TC3 : Firm Quotes : Validate Firm Quotes Response Payload : currency != PHP
    [Tags]      FirmQuotes:TC3     FirmQuotes
    ${response}=      Validate Firm Quotes Response Parameters  3    ${column_offset}    ${column}
    Log  ${response} 


    
