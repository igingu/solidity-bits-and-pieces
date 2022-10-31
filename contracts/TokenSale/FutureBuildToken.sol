// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC20/ERC20.sol";

contract FutureBuildToken is ERC20 {
    constructor(uint256 totalSupply_)
        ERC20(totalSupply_, 18, "FutureBuildToken", "FtrTkn")
    {}
}
