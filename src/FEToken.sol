pragma solidity >= 0.8.0;

import "./ERC/ERC20.sol";
import "./Interfaces/IERC20.sol";

// Contract expects external injection of underlying tokens in order to maintain the generation of interest for infinite deposits at a 5% APY
// Fake Euler Token
contract FEToken is ERC20 {

    uint256 immutable public underlyingDecimals;

    address immutable public underlyingAsset;

    uint256 public exchangeRate = 1000000000000000000;

    uint256 public rateDenominator = 20; // Equivalent of 5% APY

    uint256 public lastTraded;

    // @param u underlying asset
    // @param n name
    // @param s symbol
    // @comment always 18 decimals
    constructor (address u, string memory n, string memory s) ERC20(n, s, 18) {
        underlyingDecimals = IERC20(u).decimals();
        underlyingAsset = u;
    }

    // Total supply of the underlying asset
    function totalSupplyUnderlying() external view returns (uint) {
        return IERC20(underlyingAsset).totalSupply();
    }

    // Converts balanceOf an accounts shares into underlying
    function balanceOfUnderlying(address account) external view returns (uint) {
        return convertBalanceToUnderlying(_balanceOf[account]);
    }

    // Converts an amount of underlying assets to eToken shares
    // Does not mutate state
    // @param _assets the amount of underlying assets
    function convertUnderlyingToBalance(uint256 _assets)
        public
        view
        returns (uint256 shares) {
            uint256 diff = block.timestamp - lastTraded;
            if (diff != 0) {
                uint256 tempExchangeRate = exchangeRate + (exchangeRate * diff/(31536000 * rateDenominator));
                return (_assets / ((tempExchangeRate / (1*10^(18 + underlyingDecimals - decimals)))));
            }
            else {
                return (_assets / ((exchangeRate / (1*10^(18 + underlyingDecimals - decimals)))));
            }
        }

    // Converts an amount of eToken shares to underlying assets
    // Does not mutate state
    // @param _shares the amount of eToken shares
    function convertBalanceToUnderlying(uint256 _shares)
        public
        view
        returns (uint256 assets) {
            uint256 diff = block.timestamp - lastTraded;
            if (diff != 0 ) {
                uint256 tempExchangeRate = exchangeRate + (exchangeRate * diff/(31536000 * rateDenominator));
                return (_shares * ((tempExchangeRate / (1*10^(18 + underlyingDecimals - decimals)))));
            }
            else {
                return (_shares * ((exchangeRate / (1*10^(18 + underlyingDecimals - decimals)))));
            } 
    }

    // Mutates state and accrues interest
    function touch() public {
        uint256 diff = block.timestamp - lastTraded;
        exchangeRate + (exchangeRate * diff/(31536000 * rateDenominator));
    }

    // Deposits an amount of underlying tokens, minting eTokens
    // @param subAccountId unused euler param
    // @param amount an amount of underlying tokens
    function deposit(uint subAccountId, uint amount) external {
        touch();
        uint256 shares = convertUnderlyingToBalance(amount);
        IERC20(underlyingAsset).transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, shares);
        lastTraded = block.timestamp;
    }

    // Withdraws an amount of underlying, burning eTokens
    // @param subAccountId unused euler param
    // @param amount an amount of underlying tokens
    function withdraw(uint subAccountId, uint amount) external {
        touch();
        uint256 shares = convertUnderlyingToBalance(amount);
        IERC20(underlyingAsset).transfer(msg.sender, amount);
        _burn(msg.sender, shares);
        lastTraded = block.timestamp;
    }

    // Mints an amount of eToken shares, depositing underlying tokens
    // @param subAccountId unused euler param
    // @param amount an amount of eToken shares
    function mint(uint subAccountId, uint amount) external {
        touch();
        uint256 assets = convertBalanceToUnderlying(amount);
        IERC20(underlyingAsset).transferFrom(msg.sender, address(this), assets);
        _mint(msg.sender, amount);
        lastTraded = block.timestamp;
    }

    // Burns an amount of eToken shares, withdrawing underlying tokens
    // @param subAccountId unused euler param
    // @param amount an amount of eToken shares
    function burn(uint subAccountId, uint amount) external {
        touch();
        uint256 assets = convertBalanceToUnderlying(amount);
        IERC20(underlyingAsset).transfer(msg.sender, assets);
        _burn(msg.sender, amount);    
        lastTraded = block.timestamp;   
    }

    // Random Euler method that transfers max amount of tokens
    // @param from the person having tokens removed
    // @param to the person receiving tokens
    function transferFromMax(address from, address to) external returns (bool) {
        if (_allowance[from][to] >= _balanceOf[from]) {
            _burn(from, _balanceOf[from]);
            _mint(to, _balanceOf[from]);
            return true;
        }
        else {
            return false;
        }
    }

    // A simple method to top off the contract with underlying tokens given there is no actual interest accrual mechanism
    function refill(uint256 amount) external {
        IERC20(underlyingAsset).transferFrom(msg.sender, address(this), amount);
    }

    function changeRate(uint256 newRateDenominator) external {
        rateDenominator = newRateDenominator;
    }
}