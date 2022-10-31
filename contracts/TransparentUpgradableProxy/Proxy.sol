// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Proxy {
    function _delegate(address implementation_) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            // calldatacopy(t, f, s)
            // Copy s bytes of data, to position f into memory at position t.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            // delegatecall(gas, to, in_offset, in_size, out_offset, out_size)
            // in_offset: offset in memory of the input
            // in_size: size of the input in bytes
            // out_offset: offset in memory of the output
            // out_size: size of the output in bytes
            let result := delegatecall(
                gas(),
                implementation_,
                0,
                calldatasize(),
                0,
                0
            )

            // Copy the returned data.
            // returndatacopy(t, f, s)
            // Copy s bytes of data, to position f into memory at position t.
            returndatacopy(0, 0, returndatasize())

            // delegatecall returns 0 on error.
            // return(t, s)
            // Return s bytes of data, starting from position t in memory
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}
