*** Settings ***
Documentation       [API Testing] PDAX Insti : Post Order
...                 Run Code : robot -d Output -i PostOrder Tests/Insti/Trades
Resource            /Users/EDCIsidro/PycharmProjects/PDAX-Insti/Resource/Insti/Trades/PostOrder.resource

*** Variables ***
${column}  10
${column_offset}    2

*** Test Cases ***
# Checks for successful request and status code=200
TC1 : Post Order : Successful Request : Status Code Check 200
    [Tags]      PostOrder:TC1     PostOrder
    ${response}=      Post Order  1    ${column_offset}    ${column}
    Log  ${response} 

# Checks the response parameter
TC2 : Post Order : Validate Post Order Response Payload : Buy
    [Tags]      PostOrder:TC2     PostOrder
    ${response}=      Validate Post Order Response Parameters  2    ${column_offset}    ${column}
    Log  ${response} 

# Checks the response parameter
TC3 : Post Order : Validate Post Order Response Payload : Sell
    [Tags]      PostOrder:TC3     PostOrder
    ${response}=      Validate Post Order Response Parameters  3    ${column_offset}    ${column}
    Log  ${response} 

# Balance Check
TC4 : Post Order : Validate Balance debit/credit : Currency= PHP : Buy
    [Tags]      PostOrder:TC4     PostOrder
    ${response}=      Validate balance credit/debit    4    ${column_offset}    ${column}
    Log  ${response} 

# Balance Check
TC5 : Post Order : Validate Balance debit/credit : Currency= PHP : Sell
    [Tags]      PostOrder:TC5     PostOrder
    ${response}=      Validate balance credit/debit    5    ${column_offset}    ${column}
    Log  ${response} 

# Balance Check
TC6 : Post Order : Validate Balance debit/credit : Currency= USDC : Buy
    [Tags]      PostOrder:TC6     PostOrder
    ${response}=      Validate balance credit/debit    6    ${column_offset}    ${column}
    Log  ${response} 

# Balance Check
TC7 : Post Order : Validate Balance debit/credit : Currency= USDC : Sell
    [Tags]      PostOrder:TC7     PostOrder
    ${response}=      Validate balance credit/debit    7    ${column_offset}    ${column}
    Log  ${response} 

# Balance Check
TC8 : Post Order : Validate Balance debit/credit : Currency= BTC : Buy
    [Tags]      PostOrder:TC8     PostOrder
    ${response}=      Validate balance credit/debit    8    ${column_offset}    ${column}
    Log  ${response} 

# Balance Check
TC9 : Post Order : Validate Balance debit/credit : Currency= BTC : Sell
    [Tags]      PostOrder:TC9     PostOrder
    ${response}=      Validate balance credit/debit    9    ${column_offset}    ${column}
    Log  ${response} 

# Balance Check
TC10 : Post Order : Validate Balance debit/credit : Currency= ETH : Buy
    [Tags]      PostOrder:TC10     PostOrder
    ${response}=      Validate balance credit/debit    10    ${column_offset}    ${column}
    Log  ${response} 

# Balance Check
TC11 : Post Order : Validate Balance debit/credit : Currency= ETH : Sell
    [Tags]      PostOrder:TC11     PostOrder
    ${response}=      Validate balance credit/debit    11    ${column_offset}    ${column}
    Log  ${response} 


