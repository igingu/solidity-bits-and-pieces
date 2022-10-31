// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Conversions {
    function uint16ToUint256(uint16 number_) external pure returns (uint256) {
        return uint256(number_);
    }

    function uint256ToUint16(uint256 number_) external pure returns (uint16) {
        return uint16(number_);
    }
}
