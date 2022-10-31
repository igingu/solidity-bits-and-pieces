// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event TransferOwnership(address indexed oldOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Ownable: onlyOwner modifier.");
        _;
    }

    function _transferOwnership(address newOwner_) internal {
        address oldOwner = _owner;
        _owner = newOwner_;
        emit TransferOwnership(oldOwner, newOwner_);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner_) external onlyOwner {
        require(
            newOwner_ != address(0),
            "Ownable: transferOwnership to newOwner_ = zero address."
        );
        _transferOwnership(newOwner_);
    }

    function renounceOwnership() external onlyOwner {
        _transferOwnership(address(0));
    }
}
