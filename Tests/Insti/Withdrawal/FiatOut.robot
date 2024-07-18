*** Settings ***
Documentation       [API Testing] PDAX Insti : Fiat Out
...                 Run Code : robot -d Output -i FiatOut Tests/Insti/Withdrawal
Resource            /Users/EDCIsidro/PycharmProjects/PDAX-Insti/Resource/Insti/Withdrawal/FiatOut.resource

*** Variables ***
${column}  51
${column_offset}    2

*** Test Cases ***
# Checks for successful request and status code=200
TC1 : Fiat Out : Successful Request : Status Code Check 200
    [Tags]      FiatOut:TC1     FiatOut
    ${response}=      Fiat Out  1    ${column_offset}    ${column}
    Log  ${response} 

# Checks the response parameter
TC2 : Fiat Out : Validate Fiat Out Response Payload
    [Tags]      FiatOut:TC2     FiatOut
    ${response}=      Validate Fiat Out Response Parameters  2    ${column_offset}    ${column}
    Log  ${response} 

# Checks debiting of the user's balance when fee type is Sender
TC3 : Fiat Out : Validate Balance Debiting : Fee Type is Sender
    [Tags]      FiatOut:TC3     FiatOut
    ${response}=      Validate balance debiting  3    ${column_offset}    ${column}
    Log  ${response} 

# Checks debiting of the user's balance when fee type is Bene
TC4 : Fiat Out : Validate Balance Debiting : Fee Type is Bene
    [Tags]      FiatOut:TC4     FiatOut
    ${response}=      Validate balance debiting  4    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is UBP
TC5 : Fiat Out : Logic Sequence : UBP Bankcode
    [Tags]      FiatOut:TC5     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  5    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is UBP but UBP Direct is down
TC6 : Fiat Out : Logic Sequence : UBP Bankcode : UBP Direct Down
    [Tags]      FiatOut:TC6     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  6    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is UBP but UBP Direct and Instapay Direct are down
TC7 : Fiat Out : Logic Sequence : UBP Bankcode : UBP Direct and Instapay Direct are Down
    [Tags]      FiatOut:TC7     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  7    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is UBP but All real time channels are down
TC8 : Fiat Out : Logic Sequence : UBP Bankcode : All Real time channels are down
    [Tags]      FiatOut:TC8     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  8    ${column_offset}    ${column}
    Log  ${response} 
    
# Checks the logic sequence when the bankcode is UBP but All real time channels are down
TC9 : Fiat Out : Logic Sequence : UBP Bankcode : Non Real Time
    [Tags]      FiatOut:TC9     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  9    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is UBP : Non Real Time
TC10 : Fiat Out : Logic Sequence : UBP Bankcode : Non Real Time : UBP Direct Down
    [Tags]      FiatOut:TC10     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  10    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is UBP : Non Real Time : UBP Direct and Instapay Direct Down
TC11 : Fiat Out : Logic Sequence : UBP Bankcode : Non Real Time : UBP Direct and Instapay Direct Down
    [Tags]      FiatOut:TC11     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  11    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is UBP : Non Real Time : All Real Time Channels Down
TC12 : Fiat Out : Logic Sequence : UBP Bankcode : Non Real Time : All Real Time Channels Down
    [Tags]      FiatOut:TC12     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  12    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is UBP : All real time and non real time channels are down
TC13 : Fiat Out : Logic Sequence : UBP Bankcode : All real time and non real time channels are down
    [Tags]      FiatOut:TC13     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  13    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is UBP : Non Real Time : UBP is down : Amount > 50k
TC14 : Fiat Out : Logic Sequence : UBP Bankcode : Non Real Time : UBP is down : Amount > 50k
    [Tags]      FiatOut:TC14     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  14    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is UBP : Non Real Time : UBP and pesonet down : Amount > 50k
TC15 : Fiat Out : Logic Sequence : UBP Bankcode : Non Real Time : UBP and pesonet down : Amount > 50k
    [Tags]      FiatOut:TC15     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  15    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is Maya : Real Time : Amount < 50k 
# **************** THIS Will Fail due to Maya Cert ******************************
TC16 : Fiat Out : Logic Sequence : Maya Bankcode : Real Time : Amount < 50k 
    [Tags]      FiatOut:TC16     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  16    ${column_offset}    ${column}
    Log  ${response} 
# Checks the logic sequence when the bankcode is Maya : Real Time : Amount < 50k : Maya Down
TC17 : Fiat Out : Logic Sequence : Maya Bankcode : Real Time : Amount < 50k : Maya Down
    [Tags]      FiatOut:TC17     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  17    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is Maya : Real Time : Amount < 50k : Maya and Instapay Down
TC18 : Fiat Out : Logic Sequence : Maya Bankcode : Real Time : Amount < 50k : Maya and Instapay Down
    [Tags]      FiatOut:TC18     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  18    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is Maya : Real Time : Amount > 50k 
TC19 : Fiat Out : Logic Sequence : Maya Bankcode : Real Time : Amount > 50k 
    [Tags]      FiatOut:TC19     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  19    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is Maya : Non Real Time : Amount < 50k 
TC20 : Fiat Out : Logic Sequence : Maya Bankcode : Non Real Time : Amount < 50k 
    [Tags]      FiatOut:TC20     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  20    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is Maya : Non Real Time : Amount > 50k 
TC21 : Fiat Out : Logic Sequence : Maya Bankcode : Non Real Time : Amount < 50k : Maya Down
    [Tags]      FiatOut:TC21     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  21    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is UBP : Real Time : Amount > 50k 
TC22 : Fiat Out : Logic Sequence : Maya Bankcode : Non Real Time : Amount < 50k : Maya and Instapay Down
    [Tags]      FiatOut:TC22     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  22    ${column_offset}    ${column}
    Log  ${response} 

# Checks the logic sequence when the bankcode is UBP : Real Time : Amount > 50k 
TC23 : Fiat Out : Logic Sequence : Maya Bankcode : Non Real Time : Amount > 50k 
    [Tags]      FiatOut:TC23     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  23    ${column_offset}    ${column}
    Log  ${response} 

# Checks the limits when the bankcode is UBP : Real Time : Amount = 10M 
TC24 : Fiat Out : Limits : UBP : Real Time : Amount = 10M 
    [Tags]      FiatOut:TC24     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  24    ${column_offset}    ${column}
    Log  ${response} 

# Checks the limits when the bankcode is UBP : Real Time : Amount = 10M 
TC25 : Fiat Out : Limits : UBP : Real Time : Amount > 10M 
    [Tags]      FiatOut:TC25     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  25    ${column_offset}    ${column}
    Log  ${response} 

# Checks the limits when the bankcode is UBP : Real Time : Amount = 10M 
TC26 : Fiat Out : Limits : Pesonet : Non Real Time : Amount = 10M 
    [Tags]      FiatOut:TC26     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  26    ${column_offset}    ${column}
    Log  ${response} 

# Checks the limits when the bankcode is UBP : Real Time : Amount = 10M 
TC27 : Fiat Out : Limits : Pesonet : Non Real Time : Amount > 10M 
    [Tags]      FiatOut:TC27     FiatOut
    ${response}=      Verifiy fiat out Logic sequence  27    ${column_offset}    ${column}
    Log  ${response} 


    



