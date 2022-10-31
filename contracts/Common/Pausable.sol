// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";
import "./Ownable.sol";

contract Pausable is Context, Ownable {
    bool private _pause;

    constructor() {
        _pause = false;
    }

    event Paused();
    event Unpaused();

    modifier whenPaused() {
        require(_pause, "Pausable: whenPaused modifier.");
        _;
    }

    modifier whenUnpaused() {
        require(!_pause, "Pausable: whenUnpaused modifier.");
        _;
    }

    function paused() public view returns (bool) {
        return _pause;
    }

    function pause() external onlyOwner whenUnpaused {
        _pause = true;
        emit Paused();
    }

    function unpause() external onlyOwner whenPaused {
        _pause = false;
        emit Unpaused();
    }
}
