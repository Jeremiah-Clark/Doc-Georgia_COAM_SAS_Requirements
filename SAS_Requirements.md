# 01 SAS Requirements

*(Ref: SAS Requirements v1.8)*

The current COAM SAS implementation is based on **SAS Protocol 6.02**.

## 01 Minimum Feature Support

- The cabinet remains enabled if disconnected from the Site Controller
- The cabinet can be configured for any number from 1–127
- **Event 70** as required by the SAS protocol
- The player must still be able to cash out if the cabinet has been disabled by **LP $01**
- Can be configured to a $0.01 denomination
- **LP $21** is used to verify the Game Pack identity
  - Two queries, using 0000 and 5555 as seeds
  - The cabinet must respond to **LP $21** within seven minutes
- Secondary SAS support is NOT required
  - Secondary SAS may not interfere with Primary SAS
  - Only the Primary SAS may control the cabinet
  - **LP $01** and **LP $02** must be disabled on Secondary SAS

## 02 Required Long Polls

- **LP $01** = Disables play
- **LP $02** = Enables play
- **LP $0E** = Disables realtime reporting
- **LP $0F** = Meters $10–$15
  - $10 = Total Cancelled Credits Meter
  - $11 = Total Coin In Meter
  - $12 = Total Coin Out Meter
  - $13 = Total Drop Meter
  - $14 = Total Jackpot Meter = 00000000  \***
  - $15 = Games Played Meter
- **LP $1A** = Current Credits on the machine
- **LP $19** = Meters $11–$15
  - $11 = Total Coin In Meter
  - $12 = Total Coin Out Meter
  - $13 = Total Drop Meter
  - $14 = Total Jackpot Meter = 00000000  \***
  - $15 = Games Played Meter
- **LP $1F**
  - $1F = Gaming Machine ID
  - $1F = Additional ID
  - $1F = Denomination = 01 \**
  - $1F = Max Bet
  - $1F = Progressive Group
  - $1F = Game Options
  - $1F = Pay Table ID
  - $1F = Base Percentage
- **LP $21** = ROM signature
- **LP $2F** = Meters (See below)
- **LP $51** = Number of games implemented
- **LP $53** = Currently selected game configuration
- **LP $54** = SAS version ID & cabinet serial number
- **LP $55** = Currently selected game number 
- **LP $56** = Number of games currently enabled
- **LP $A0** = Enabled features

## 03 Required Meters

- **0000** = Total Coin In
- **0001** = Total Coin Out
- **0002** = Total Jackpot credits = 0000 \***
- **0003** = Total Hand Paid Cancelled Credits = 0000 \*
- **0004** = Total Cancelled Credits
- **0005** = Games Played
- **0006** = Games Won
- **0007** = Games Lost
- **000B** = Total Credits from Bill Accepter
- **000C** = Current Credits
- **0015** = Total Ticket In
- **0016** = Total Ticket Out
- **001C** = Total Machine Paid Paytable Win
- **001D** = Total Machine Paid Progressive Win = 0000 \*
- **001E** = Total Machine Paid external bonus win = 0000 \*
- **001F** = Total Attendant Paid Paytable Win = 0000 \*
- **0020** = Total Attendant Paid Progressive Win = 0000 \*
- **0021** = Total Attendant Paid External Bonus = 0000 \*
- **0022** = Total Won Credits
- **0023** = Total Hand Paid Credits = 0000 \*
- **0024** = Total Drop
- **0040-0057** = Total number of X bills accepted

> [!NOTE]
>
> 1. \* The “attendant paid” and “hand paid” meters will remain at “0000”  
> 2. \*\* Denomination will always be “01”  
> 3. \*\*\* “Jackpot” meters will remain at “00000000”

## 04 Required Events

- **$15** = Logic Box Opened
- **$16** = Logic Box Closed
- **$17** = AC power applied to gaming machine
- **$18** = AC power lost from gaming machine
- **$3B** = Low backup battery detected
- **$3C** = Operator changed options
- **$51** = Handpay is pending
- **$52** = Handpay was reset
- **$70** = Exception buffer overflow
- **$7A** = Gaming machine soft meter reset
- **$98** = Power off card cage access
