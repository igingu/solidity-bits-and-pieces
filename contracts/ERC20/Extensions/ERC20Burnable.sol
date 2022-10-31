// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC20.sol";

contract ERC20Burnable is ERC20 {
    constructor(
        uint256 initialSupply_,
        uint256 decimals_,
        string memory name_,
        string memory symbol_
    ) ERC20(initialSupply_, decimals_, name_, symbol_) {}

    modifier onlySender(address account_) {
        require(_msgSender() == account_);
        _;
    }

    function burn(uint256 amount_) external virtual onlySender(_msgSender()) {
        _burn(_msgSender(), amount_);
    }

    function burnFrom(address account_, uint256 amount_)
        external
        virtual
        onlySender(_msgSender())
    {
        _spendAllowance(account_, _msgSender(), amount_);
        _burn(account_, amount_);
    }
}
