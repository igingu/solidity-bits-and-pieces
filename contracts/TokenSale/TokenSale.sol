// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Common/Ownable.sol";
import "../Common/Pausable.sol";
import "./FutureBuildToken.sol";
import "./Disbursement.sol";

contract TokenSale is Ownable, Pausable {
    uint256 private _price;
    address payable private _saleWallet;
    uint64 private _startTime;
    FutureBuildToken private _token;
    uint64 private _freezeTime;

    bool private _deactivated = false;

    event TokensPurchased(address indexed buyer, uint256 amount);
    event TokensDistributedToPrebuyer(address indexed preBuyer, uint256 amount);
    event TokensDistributedToTimelocks(
        address indexed timelock,
        uint256 startTime,
        uint256 vestingPeriod,
        uint256 amount
    );

    modifier saleStarted() {
        require(
            block.timestamp >= _startTime,
            "TokenSale: saleStarted modifier."
        );
        _;
    }

    modifier saleNotStarted() {
        require(
            block.timestamp < _startTime,
            "TokenSale: saleNotStarted modifier."
        );
        _;
    }

    modifier saleNotFrozen() {
        require(
            block.timestamp <= _freezeTime,
            "TokenSale: saleNotFrozen modifier."
        );
        _;
    }

    modifier notDeactivated() {
        require(!_deactivated, "TokenSale: notDeactivated modifier.");
        _;
    }

    constructor(
        uint256 totalSupply_,
        uint64 startTime_,
        uint64 freezeTime_,
        uint256 price_,
        address payable saleWallet_,
        address[] memory preBuyers,
        uint256[] memory preBuyersAmounts,
        address[] memory timeLocks,
        uint64[] memory timeLockStarts,
        uint64[] memory vestingPeriods,
        uint256[] memory timeLocksAmounts
    ) {
        if (startTime_ == 0) {
            startTime_ = block.timestamp;
        }

        if (freezeTime_ == 0) {
            freezeTime_ = block.timestamp + 90 days;
        }
        require(
            totalSupply_ > 0,
            "TokenSale: constructor with totalSupply_ = zero."
        );
        require(
            block.timestamp <= startTime_,
            "TokenSale: constructor with startTime_ in the past."
        );
        require(
            startTime_ < freezeTime_,
            "TokenSale: constructor with freezeTime_ before startTime_."
        );
        require(price_ > 0, "TokenSale: constructor with price_ = zero.");
        require(
            saleWallet_ != address(0),
            "TokenSale: constructor with saleWallet_ = zero address."
        );

        _token = new FutureBuildToken(totalSupply_);

        _startTime = startTime_;
        _freezeTime = freezeTime_;
        _price = price_;
        _saleWallet = saleWallet_;

        _distributeTokensToPrebuyers(preBuyers, preBuyersAmounts);
        _distributeTokensToTimelocks(
            timeLocks,
            timeLockStarts,
            vestingPeriods,
            timeLocksAmounts
        );
    }

    function _distributeTokensToPrebuyers(
        address[] memory preBuyers,
        uint256[] memory amounts
    ) private {
        require(
            preBuyers.length == amounts.length,
            "TokenSale: _distributeTokensToPrebuyers arrays of different lengths."
        );

        for (uint256 i = 0; i < preBuyers.length; i++) {
            _token.transfer(preBuyers[i], amounts[i]);
            emit TokensDistributedToPrebuyer(preBuyers[i], amounts[i]);
        }
    }

    function _distributeTokensToTimelocks(
        address[] memory timeLocks,
        uint64[] memory timeLockStarts,
        uint64[] memory vestingPeriods,
        uint256[] memory amounts
    ) private {
        require(
            timeLocks.length == amounts.length,
            "TokenSale: distributeTokensToTimelocks arrays timeLocks and amounts of different lengths."
        );
        require(
            timeLockStarts.length == amounts.length,
            "TokenSale: distributeTokensToTimelocks arrays timeLocks and timeLockStarts of different lengths."
        );
        require(
            timeLocks.length == amounts.length,
            "TokenSale: distributeTokensToTimelocks arrays timeLocks and vestingPeriods of different lengths."
        );

        for (uint256 i = 0; i < timeLocks.length; i++) {
            if (timeLockStarts[i] == 0) {
                timeLockStarts[i] = block.timestamp;
            }
            Disbursement disbursement = new Disbursement(
                timeLocks[i],
                timeLockStarts[i],
                vestingPeriods[i],
                _token
            );
            _token.transfer(address(disbursement), amounts[i]);
            emit TokensDistributedToTimelocks(
                timeLocks[i],
                timeLockStarts[i],
                vestingPeriods[i],
                amounts[i]
            );
        }
    }

    function changePrice(uint256 price_) external onlyOwner notDeactivated {
        require(price_ > 0, "TokenSale: changePrice with price_ = zero.");
        _price = price_;
    }

    function changeStartTime(uint256 startTime_)
        external
        onlyOwner
        saleNotStarted
    {
        require(
            block.timestamp < startTime_,
            "TokenSale: changeStartTime with startTime_ in the past."
        );
        require(
            startTime_ < _freezeTime,
            "TokenSale: changeStartTime with freezeTime_ before startTime_."
        );
        _startTime = startTime_;
    }

    function changeFreezeTime(uint256 freezeTime_)
        external
        onlyOwner
        saleNotStarted
    {
        require(
            _startTime < freezeTime_,
            "TokenSale: changeFreezeTime with freezeTime_ before startTime_."
        );
        _freezeTime = freezeTime_;
    }

    function changeSaleWallet(address payable saleWallet_) external onlyOwner {
        require(
            saleWallet_ != address(0),
            "TokenSale: changeSaleWallet with saleWallet_ = zero address."
        );
        _saleWallet = saleWallet_;
    }

    function purchaseTokens()
        external
        payable
        saleStarted
        saleNotFrozen
        whenUnpaused
    {
        uint256 valueInWei = _msgValue();

        unchecked {
            uint256 weiExcess = valueInWei % _price;
            uint256 tokensToBuy = valueInWei / _price;
        }

        require(
            tokensToBuy >= _token.balanceOf(address(this)),
            "TokenSale: purchaseTokens for more tokens than available."
        );

        if (weiExcess > 0) {
            address payable buyer = payable(_msgSender());
            buyer.transfer(weiExcess);
        }

        _saleWallet.transfer(valueInWei - weiExcess);

        _token.transfer(_msgSender(), tokensToBuy);

        emit TokensPurchased(_msgSender(), tokensToBuy);
    }
}
