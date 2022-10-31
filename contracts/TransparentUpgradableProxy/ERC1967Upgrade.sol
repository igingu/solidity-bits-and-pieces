// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./StorageSlot.sol";

contract ERC1967Upgrade {
    event ImplementationUpgraded(address indexed newImplementation);
    event AdminChanged(address indexed newAdmin);

    bytes32 private constant IMPLEMENTATION_SLOT =
        keccak256(abi.encodePacked("eip1967.proxy.implementation"));
    bytes32 private constant ADMIN_SLOT =
        keccak256(abi.encodePacked("eip1967.proxy.admin"));

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address implementation_) internal {
        require(
            Address.isContract(implementation_),
            "ERC1967Upgrade: _setImplementation with implementation_ being external account."
        );
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = implementation_;
    }

    function _upgradeTo(address implementation_) internal {
        _setImplementation(implementation_);
        emit ImplementationUpgraded(implementation_);
    }

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    function _setAdmin(address admin_) internal {
        require(
            admin_ != address(0),
            "ERC1967Upgrade: _setAdmin with admin_ = zero address."
        );
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = admin_;
    }

    function _changeAdmin(address admin_) internal {
        _setAdmin(admin_);
        emit AdminChanged(admin_);
    }
}
