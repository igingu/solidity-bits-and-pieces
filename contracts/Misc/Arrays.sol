// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Arrays {
    string private _contractName = "Arrays";

    int256[] _dinamicallySizedArray;

    bool private _locked;
    uint public x = 10;

    modifier noReentrancy() {
        require(!_locked, "Already locked.");
        _locked = true;
        _;
        _locked = false;
    }

    function decrement(uint256 i) public noReentrancy {
        x -= i;
        if (i > 1) {
            decrement(i - 1);
        }
    }

    function contractName() external view returns (string memory) {
        return _contractName;
    }

    function dinamicallySizedArray() external returns (int256[] memory) {
        _dinamicallySizedArray.push(0);
        _dinamicallySizedArray.push(1);

        return _dinamicallySizedArray;
    }

    function _fixeSizedArrays()
        internal
        pure
        returns (uint256[5] memory, uint256[5] memory)
    {
        uint256[5] memory data1 = [uint256(1), 2, 3, 4, 5];
        uint256[5] memory data2 = [uint256(6), 7, 8, 9, 10];

        return (data1, data2);
    }

    function fixeSizedArray1() external pure returns (uint256[5] memory) {
        (uint256[5] memory array1, ) = _fixeSizedArrays();

        return array1;
    }

    function fixeSizedArray2() external pure returns (uint256[5] memory) {
        (, uint256[5] memory array2) = _fixeSizedArrays();

        return array2;
    }

    enum BooleanChoice {
        False,
        True
    }
    BooleanChoice falseChoice = BooleanChoice.False;
    BooleanChoice trueChoice = BooleanChoice.True;

    function testEnum() external pure returns (BooleanChoice) {
        return BooleanChoice.True; // Returns 1
    }

    function and(bytes1 b1, bytes1 b2) external pure returns (bytes1) {
        return b1 & b2;
    }

    function or(bytes1 b1, bytes1 b2) external pure returns (bytes1) {
        return b1 | b2;
    }

    function xor(bytes1 b1, bytes1 b2) external pure returns (bytes1) {
        return b1 ^ b2;
    }

    function not(bytes1 b1) external pure returns (bytes1) {
        return ~b1;
    }

    function leftShift(bytes1 a, uint256 n) external pure returns (bytes1) {
        return a << n;
    }

    function rightShift(bytes1 a, uint256 n) external pure returns (bytes1) {
        return a >> n;
    }

    function stringToBytesArray(string memory someString_) external pure returns (bytes memory) {
        return bytes(someString_);
    }

    function bytesArrayToString(bytes memory someBytes_) external pure returns (string memory) {
        return string(someBytes_);
    }

    function bytesArrayToStringIteration(bytes memory someBytes_) external pure returns (string memory) {
        bytes1[] memory byteArray = new bytes1[](someBytes_.length);

        for (uint256 i = 0; i < someBytes_.length; i++) {
           byteArray[i] = someBytes_[i];
        }

        return string(abi.encode(byteArray));
    }


    function otherConversions() external pure returns (uint64, uint32, uint96, bytes12, bytes12, bytes12, bytes4) {
        bytes8 _exampleBytes = 0x11030330f020D5C5;

        uint64 v1 = uint64(_exampleBytes);
        // not possible
        // uint32 v2 = uint32(_exampleBytes);
        uint32 v2 = uint32(v1);

        // not possible
        // uint96 v3 = uint96(_exampleBytes);
        uint96 v3 = uint96(v1);

        // not possible
        // bytes12 b = bytes12(v1); bytes12 b = bytes12(v2); bytes4 b = bytes4(v3);
        bytes12 b = bytes12(v3);
        bytes12 b1 = bytes4(v2);
        bytes12 b2 = bytes8(v1);

        bytes4 b3 = bytes4(_exampleBytes);


        return (v1, v2, v3, b, b1, b2, b3);
    }

    function otherConversions2() external pure returns (bytes memory, bytes3, bytes2, bytes1, bytes20, bytes32, bytes32) {
        string memory s = "abcd";
        bytes memory b4 = bytes(s);

        // not possible
        //bytes3 b5 = bytes3(s);
        bytes3 b5 = bytes3(b4);
        bytes2 b6 = bytes2(b4);
        bytes1 b7 = bytes1(b4);

        //address conversion
        address a1 = 0x2014a9707099DFcbA3Bb91D23b31cF7Be61941d9;
        bytes20 b8 = bytes20(a1); // works
        bytes32 b9 = bytes32(abi.encode(a1)); //works

        //bool conversion
        bytes32 b10 = bytes32(abi.encode(true)); //works

        return (b4, b5, b6, b7, b8, b9, b10);
    }
}
