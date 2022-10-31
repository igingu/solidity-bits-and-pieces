// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1967Upgrade.sol";
import "./Proxy.sol";

contract ERC1967Proxy is ERC1967Upgrade, Proxy {
    event ERC1967ProxyConstructed(address indexed implementation);

    constructor(address implementation_) {
        ERC1967Upgrade._setImplementation(implementation_);
        emit ERC1967ProxyConstructed(implementation_);
    }

    function _implementation()
        internal
        view
        virtual
        override
        returns (address)
    {
        return ERC1967Upgrade._getImplementation();
    }
}
