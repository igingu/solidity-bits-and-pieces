// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../Ownable.sol";

contract ERC20Burnable is ERC20, Ownable {
    address private _owner;

    constructor(
        uint256 initialSupply_,
        uint256 decimals_,
        string memory name_,
        string memory symbol_
    ) ERC20(initialSupply_, decimals_, name_, symbol_) {}

    function mint(address account_, uint256 amount_)
        external
        virtual
        onlyOwner
    {
        _mint(account_, amount_);
    }
}
