// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contract that can receive ether from others, and withdraw everything if owner.
contract EtherWallet {
    address payable private _owner;

    modifier onlyOwner() {
        require(msg.sender == _owner, "EtherWallet: onlyOwner modifier.");
        _;
    }

    constructor() {
        _owner = payable(msg.sender);
    }

    receive() external payable {}

    function withdraw(uint256 amount) external onlyOwner {
        _owner.transfer(amount);
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}
