// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Origins {
    event FunctionSignature(bytes4 indexed signature);

    function msgSenderOtherContract() external returns (address) {
        OriginsSecondary os = new OriginsSecondary();
        return os.msgSender();
    }

    function txOriginOtherContract() external returns (address) {
        OriginsSecondary os = new OriginsSecondary();
        return os.txOrigin();
    }

    function msgDataOtherContract() external returns (bytes memory) {
        OriginsSecondary os = new OriginsSecondary();
        return os.msgData();
    }

    function msgSigOtherContract() external returns (bytes4) {
        OriginsSecondary os = new OriginsSecondary();
        emit FunctionSignature(this.msgSigOtherContract.selector);
        return os.msgSig();
    }
}

contract OriginsSecondary {
    event FunctionSignature(bytes4 indexed signature);

    function msgSender() public view returns (address) {
        return msg.sender;
    }

    function txOrigin() public view returns (address) {
        return tx.origin;
    }

    function msgData() public pure returns (bytes memory) {
        return msg.data;
    }

    function msgSig() public returns (bytes4) {
        emit FunctionSignature(this.msgSig.selector);
        return msg.sig;
    }
}
