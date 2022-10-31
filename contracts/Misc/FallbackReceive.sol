// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FallbackReceive {
    event Fallback(uint256 amount);
    event Receive(uint256 amount);

    fallback() external payable {
        emit Fallback(msg.value);
    }

    receive() external payable {
        emit Receive(msg.value);
    }
}

contract Fallback2 {
    event Log(string func, uint gas);

    // Fallback function must be declared as external.
    fallback() external payable {
        // send / transfer (forwards 2300 gas to this fallback function)
        // call (forwards all of the gas)
        emit Log("fallback", gasleft());
    }

    // Receive is a variant of fallback that is triggered when msg.data is empty
    receive() external payable {
        emit Log("receive", gasleft());
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract SendToFallback {
    function transferToFallback(address payable _to) public payable {
        _to.transfer(msg.value);
    }

    function callFallback(address payable _to) public payable {
        (bool sent, ) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}
