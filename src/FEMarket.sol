pragma solidity >= 0.8.0;

import "./Interfaces/IERC20.sol";
import "./FEToken.sol";
import "./FDToken.sol";

// Contract expects external injection of underlying tokens in order to maintain the generation of interest for infinite deposits at a 5% APY
// Fake Euler Token
contract FEMarket {

    mapping(address => int96) public InterestRates;

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

    constructor (uint32 _reserveFee, uint256 _rateModel, address _chainlinkAggregator, address[] memory _entered) {
        reserveFee = _reserveFee;
        rateModel = _rateModel;
        chainlinkAggregator = _chainlinkAggregator;
        entered = _entered;
    }

    function interestRateModel(address underlying) external view returns (uint) {
        return (rateModel);
    }

    function activateMarket(address underlying, int96 _interestRate) external returns (address) {
        FEToken _FEToken = new FEToken(underlying, string.concat("FE",IERC20(underlying).name()), string.concat("FE",IERC20(underlying).symbol()));
        FDToken _FDToken = new FDToken(underlying, string.concat("FD",IERC20(underlying).name()), string.concat("FD",IERC20(underlying).symbol()));
        Markets[underlying] = market(address(_FEToken), address(_FDToken));
        ETokenstoDTokens[address(_FEToken)] = address(_FDToken);
        InterestRates[underlying] = _interestRate;
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
        return (FDToken(dToken).underlyingAsset());
    }

    function eTokenToDToken(address eToken) external view returns (address dTokenAddr) {
        return (ETokenstoDTokens[eToken]);
    }

    function interestRate(address underlying) external view returns (int96) {
        return (InterestRates[underlying]);
    }

    function getPricingConfig(address underlying) external view returns (uint16 pricingType, uint32 pricingParameters, address pricingForwarded) {
        return (uint16(1), uint32(0), address(0));
    }

    function getChainlinkPriceFeedConfig(address underlying) external view returns (address _chainlinkAggregator) {
        return (chainlinkAggregator);
    }

    function getEnteredMarkets(address account) external view returns (address[] memory) {
        return (entered);
    }

    function enterMarket(uint subAccountId, address newMarket) external {
    }

    function exitMarket(uint subAccountId, address oldMarket) external {
    }

    function setInterestRate(address underlying, int96 _interestRate) external {
        InterestRates[underlying] = _interestRate;
    }
}