# Fake-Euler
 A Fake Euler Protocol for development purposes

Fake Euler Markets:
- Basic market activation (creates dToken, eToken, maps markets)
- Basic read methods
- Missing:
    - PTokens
    - Asset Configs

Fake Euler eToken:
- Basic interest generation (settable APY)
- Deposit/Withdraw/Mint/Burn functionality
- Basic read methods
- Missing:
    - `approveSubAccount`
    - `donateToReserves`

Fake Euler dToken:
- Basic read methods
- Borrow/Repay at 1:1 amounts
- Flash Loans
- Missing:
    - Debt accrual mechanism
    - Account approval mechanism
    - Debt approval mechanism
