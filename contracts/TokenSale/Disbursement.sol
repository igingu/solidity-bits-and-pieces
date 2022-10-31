// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC20/ERC20.sol";
import "../Common/Context.sol";

// Should have an owner and a receiver
// Receiver should be able to withdraw finds
// Should have a start time and a vesting period

contract Disbursement is Context {
    address private _receiver;
    uint64 private _startTime;
    uint256 private _tokensWithdrawn;
    ERC20 private _token;
    uint64 private _vestingPeriod;

    modifier onlyReceiver() {
        require(
            _msgSender() == _receiver,
            "Disbursement: onlyReceiver modifier."
        );
        _;
    }

    modifier vestingStarted() {
        require(
            block.timestamp >= _startTime,
            "Disbursement: vestingStarted modifier."
        );
        _;
    }

    constructor(
        address receiver_,
        uint64 startTime_,
        uint64 vestingPeriod_,
        ERC20 token_
    ) {
        require(
            receiver_ != address(0),
            "Disbursement: constructor with receiver_ = zero address."
        );
        require(vestingPeriod_ != 0, "Disbursement: vestingPeriod_ = zero.");

        if (startTime_ != 0) {
            require(
                startTime_ >= block.timestamp,
                "Disbursement: constructor with startTime_ in the past."
            );
        }

        _receiver = receiver_;
        _startTime = (startTime_ == 0 ? block.timestamp : startTime_);
        _vestingPeriod = (vestingPeriod_ == 0 ? 90 days : vestingPeriod_);
        _token = token_;
    }

    function _computeMaxTokensToWithdraw() private view returns (uint256) {
        uint256 maxTokensToWithdraw = ((_token.balanceOf(address(this)) +
            _tokensWithdrawn) * (block.timestamp - _startTime)) /
            _vestingPeriod;
        return maxTokensToWithdraw - _tokensWithdrawn;
    }

    function withdrawTokens(address to_, uint256 amount_)
        external
        onlyReceiver
        vestingStarted
    {
        uint256 maxTokensToWithdraw = _computeMaxTokensToWithdraw();

        require(
            maxTokensToWithdraw >= amount_,
            "Disbursement: withdrawTokens with amount_ > available tokens to withdraw."
        );

        unchecked {
            _tokensWithdrawn += amount_;
        }
        _token.transfer(to_, amount_);
    }
}
