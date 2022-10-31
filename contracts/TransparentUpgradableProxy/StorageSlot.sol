// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BoolSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot)
        internal
        pure
        returns (AddressSlot storage s)
    {
        assembly {
            s.slot := slot
        }
    }

    function getBoolSlot(bytes32 slot)
        internal
        pure
        returns (BoolSlot storage s)
    {
        assembly {
            s.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot)
        internal
        pure
        returns (Bytes32Slot storage s)
    {
        assembly {
            s.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot)
        internal
        pure
        returns (Uint256Slot storage s)
    {
        assembly {
            s.slot := slot
        }
    }
}
