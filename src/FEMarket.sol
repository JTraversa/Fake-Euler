pragma solidity >= 0.8.0;

import "./Interfaces/IERC20.sol";
import "./FEToken.sol";

// Contract expects external injection of underlying tokens in order to maintain the generation of interest for infinite deposits at a 5% APY
// Fake Euler Token
contract FEMarket {

    uint96 public interestRate;

    uint32 public reserveFee;

    uint256 public rateModel;

    address public chainlinkAggregator;

    struct market {
        address EToken;
        address DToken;
    }

    mapping(address => address) ETokenstoDTokens;

    mapping(address => market) Markets;

    address[] public entered;

    constructor (uint96 _interestRate, uint32 _reserveFee, uint256 _rateModel, address _chainlinkAggregator, address[] _entered) {
        interestRate = _interestRate;
        reserveFee = _reserveFee;
        rateModel = _rateModel;
        chainlinkAggregator = _chainlinkAggregator;
        entered = _entered;
    }

    function interestRateModel(address underlying) external view returns (uint) {
        return (rateModel);
    }

    function activateMarket(address underlying) external returns (address) {
        FEToken _FEToken = FEToken(underlying, string.concat("FE",IERC20(underlying).name()), string.concat("FE",IERC20(underlying).symbol()));
        FEToken _DEToken = FEToken(underlying, string.concat("DE",IERC20(underlying).name()), string.concat("DE",IERC20(underlying).symbol()));
        Markets[underlying] = new market(_FEToken,_DEToken);
        eTokenstodTokens[_FEToken] = _DEToken;
    }

    function underlyingToEToken(address underlying) external view returns (address) {
        return (Markets[underlying].EToken);
    }

    function underlyingToDToken(address underlying) external view returns (address) {
        return (Markets[underlying].DToken);
    }

    function eTokenToUnderlying(address eToken) external view returns (address underlying) {
        return (FEToken(eToken).underlyingAsset());
    }

    function dTokenToUnderlying(address dToken) external view returns (address underlying) {
        return (FEToken(eToken).underlyingAsset());
    }

    function eTokenToDToken(address eToken) external view returns (address dTokenAddr) {
        return (eTokenstodTokens[eToken]);
    }

    function getPricingConfig(address underlying) external view returns (uint16 pricingType, uint32 pricingParameters, address pricingForwarded) {
        return (1, 0, 0);
    }

    function getChainlinkPriceFeedConfig(address underlying) external view returns (address chainlinkAggregator) {
        return (chainlinkAggregator);
    }

    function getEnteredMarkets(address account) external view returns (address[] memory) {
        return (entered);
    }

    function enterMarket(uint subAccountId, address newMarket) external {
    }

    function exitMarket(uint subAccountId, address oldMarket) external {
    }

}