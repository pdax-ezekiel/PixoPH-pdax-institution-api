*** Settings ***
Documentation       [API Testing] PDAX Insti : Crypto Out
...                 Run Code : robot -d Output -i CryptoOut Tests/Insti/Withdrawal
Resource            /Users/EDCIsidro/PycharmProjects/PDAX-Insti/Resource/Insti/Withdrawal/CryptoOut.resource

*** Variables ***
${column}  14
${column_offset}    2

*** Test Cases ***
# Checks for successful request and status code=200
TC1 : Crypto Out : Successful Request : Status Code Check 200
    [Tags]      CryptoOut:TC1     CryptoOut
    ${response}=      Crypto Out  1    ${column_offset}    ${column}
    Log  ${response} 

TC2 : Crypto Out : Required Parameter : Missing Amount
    [Tags]      CryptoOut:TC2     CryptoOut
    ${response}=      Verify Required Parameters  2    ${column_offset}    ${column}
    Log  ${response} 

TC3 : Crypto Out : Required Parameter : Missing Currency
    [Tags]      CryptoOut:TC3     CryptoOut
    ${response}=      Verify Required Parameters  3    ${column_offset}    ${column}
    Log  ${response} 
    
TC4 : Crypto Out : Required Parameter : Missing Address
    [Tags]      CryptoOut:TC4     CryptoOut
    ${response}=      Verify Required Parameters  4    ${column_offset}    ${column}
    Log  ${response} 

TC5 : Crypto Out : Required Parameter : Amount More than 50K PHP : Missing Beneficiary First Name
    [Tags]      CryptoOut:TC5     CryptoOut
    ${response}=      Verify Required Parameters  5    ${column_offset}    ${column}
    Log  ${response} 

TC6 : Crypto Out : Required Parameter : Amount More than 50K PHP : Missing Beneficiary Last Name
    [Tags]      CryptoOut:TC6     CryptoOut
    ${response}=      Verify Required Parameters  6    ${column_offset}    ${column}
    Log  ${response} 

TC7 : Crypto Out : Required Parameter : Amount More than 50K PHP : Missing Beneficiary Exchange
    [Tags]      CryptoOut:TC7     CryptoOut
    ${response}=      Verify Required Parameters  7    ${column_offset}    ${column}
    Log  ${response} 

TC8 : Crypto Out : Required Parameter : Amount More than 50K PHP : Missing Name but send_to_self set to true
    [Tags]      CryptoOut:TC8     CryptoOut
    ${response}=      Crypto Out  8    ${column_offset}    ${column}
    Log  ${response} 

TC9 : Crypto Out : Required Parameter : Amount More than 50K PHP : Missing Name and beneficiary_exchange but send_to_self and beneficiary_wallet set to true 
    [Tags]      CryptoOut:TC9     CryptoOut
    ${response}=      Crypto Out  9    ${column_offset}    ${column}
    Log  ${response} 

TC10 : Crypto Out : Response Parameter check
    [Tags]      CryptoOut:TC10     CryptoOut
    ${response}=      Verify Response Parameter  10    ${column_offset}    ${column}
    Log  ${response} 

TC11 : Crypto Out : Verify Debiting : USDC-ERC20
    [Tags]      CryptoOut:TC11     CryptoOut
    ${response}=      Verify debiting  11    ${column_offset}    ${column}
    Log  ${response} 


TC12 : Crypto Out : Verify Debiting : BTC
    [Tags]      CryptoOut:TC12     CryptoOut
    ${response}=      Verify debiting  12    ${column_offset}    ${column}
    Log  ${response} 


TC13 : Crypto Out : Verify Debiting : USDCXLM
    [Tags]      CryptoOut:TC13     CryptoOut
    ${response}=      Verify debiting  13    ${column_offset}    ${column}
    Log  ${response} 



    

