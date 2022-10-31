// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1967Proxy.sol";

contract TransparentUpgradableProxy is ERC1967Proxy {
    constructor(address implementation_) ERC1967Proxy(implementation_) {
        _changeAdmin(msg.sender);
    }

    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external view returns (address admin_) {
        admin_ = _getAdmin();
    }

    function implementation() external view returns (address implementation_) {
        implementation_ = _implementation();
    }

    function changeAdmin(address admin_) external ifAdmin {
        _changeAdmin(admin_);
    }

    function upgradeTo(address implementation_) external ifAdmin {
        _setImplementation(implementation_);
    }

    function _beforeFallback() internal virtual override {
        require(
            msg.sender != _getAdmin(),
            "TransparentUPgradableProxy: _beforeFallback with non-admin."
        );
        super._beforeFallback();
    }
}
