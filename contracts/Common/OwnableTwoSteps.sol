// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";

contract OwnableTwoSteps is Context {
    address public owner;
    address private _newOwner;

    event OwnershipTransferedEvent(address indexed from_, address indexed to_);
    event OwnershipTransferedFirstStep(
        address indexed from_,
        address indexed to_
    );
    event OwnershipTransferedSecondStep(address indexed to_);
    event OwnershipRenounced(address indexed by_);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        require(owner == _msgSender(), "OwnableTwoSteps: onlyOwner modifier.");
        _;
    }

    modifier onlyNewOwner() {
        require(
            _newOwner == _msgSender(),
            "OwnableTwoSteps: onlyNewOwner modifier."
        );
        _;
    }

    modifier notInProgress() {
        require(
            _newOwner == address(0),
            "OwnableTwoSteps: notInProgress modifier."
        );
        _;
    }

    function transferOwnershipTwoSteps(address to_)
        external
        onlyOwner
        notInProgress
    {
        require(
            to_ != address(0),
            "OwnableTwoSteps: transferOwnershipTwoSteps with to_ = zero address."
        );
        _newOwner = to_;
        emit OwnershipTransferedFirstStep(owner, _newOwner);
    }

    function acceptOwnershipTwoSteps() external onlyNewOwner {
        _transferOwnership(_msgSender());
        _newOwner = address(0);
        emit OwnershipTransferedSecondStep(_msgSender());
    }

    function renounceOwnership() external onlyOwner notInProgress {
        owner = address(0);
        emit OwnershipRenounced(_msgSender());
    }

    function _transferOwnership(address to_) internal {
        address oldOwner = owner;
        owner = to_;
        emit OwnershipTransferedEvent(oldOwner, to_);
    }
}
