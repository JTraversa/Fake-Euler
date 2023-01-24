pragma solidity >= 0.8.0;

import "./ERC/ERC20.sol";
import "./Interfaces/IERC20.sol";

// Contract expects external injection of underlying tokens in order to maintain the generation of interest for infinite deposits at a 5% APY
// Fake Euler Token
contract FDToken is ERC20 {

    uint256 immutable public underlyingDecimals;

    address immutable public underlyingAsset;

    uint256 public debtAllowance = 100000000000000000000;

    uint256 public lastTraded;

    // @param u underlying asset
    // @param n name
    // @param s symbol
    // @comment always 18 decimals
    constructor (address u, string memory n, string memory s) ERC20(n, s, 18) {
        underlyingDecimals = IERC20(u).decimals();
        underlyingAsset = u;
    }

    function totalSupplyExact() external view returns (uint){
        return (totalSupply * 10e9);
    }

    function balanceOfExact(address user) external view returns (uint){
        return (_balanceOf[user] * 10e9);
    }

    // Borrows by minting dTokens and receiving underlying
    // @param subAccountId unused euler param
    // @param amount an amount of underlying tokens
    function borrow(uint subAccountId, uint amount) external {
        IERC20(underlyingAsset).transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
        lastTraded = block.timestamp;
    }

    // "Repays" debt by sending underlying and burning dTokens
    // @param subAccountId unused euler param
    // @param amount an amount of underlying tokens
    function repay(uint subAccountId, uint amount) external {
        IERC20(underlyingAsset).transfer(msg.sender, amount);
        _burn(msg.sender, amount);
        lastTraded = block.timestamp;
    }

    function flashLoan(uint amount, bytes calldata data) external {
        uint256 initialBalance = IERC20(underlyingAsset).balanceOf(address(this));
        IERC20(underlyingAsset).transfer(msg.sender, amount);
        (bool success, bytes memory result) = address(this).delegatecall(
                data
            );

        if (!success) revert(RevertMsgExtractor.getRevertMsg(result));
        require(IERC20(underlyingAsset).balanceOf(address(this)) >= initialBalance);
    }
    
    function approveDebt(uint subAccountId, address spender, uint amount) external returns (bool){
        return(true);
    }

    // A simple method to top off the contract with underlying tokens given there is no actual interest accrual mechanism
    function refill(uint256 amount) external {
        IERC20(underlyingAsset).transferFrom(msg.sender, address(this), amount);
    }

    function changeDebtAllowance(uint256 newAllowance) external {
        debtAllowance = newAllowance;
    }

}