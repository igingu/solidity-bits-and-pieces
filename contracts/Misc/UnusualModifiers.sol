// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UnusualModifiers {
    // Only allows initialization, no assignment
    bool private constant _constantValue = true;

    // Allows only one assignment at construction time
    bool private immutable _immutableValue = true;

    event AnonymousEvent(uint256 indexed value) anonymous;
    event Event(uint256 indexed value);

    constructor() {}

    function anonymousEvent() external {
        emit AnonymousEvent(0);
        emit Event(0);
    }

    function multipleReturns() internal pure returns (uint256 x, uint256 y) {
        x = 5;
        y = 7;
    }

    function destructuringAssignment() external pure returns (uint256 x, uint256 y, uint256 z) {
        (, x) = multipleReturns();
        (y, z) = multipleReturns();

        return (x, y, z);
    }
}
