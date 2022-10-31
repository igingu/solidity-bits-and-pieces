// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../Pausable.sol";

// ERC20 Contract with pause functionality for all transfers;

abstract contract ERC20Pausable is ERC20, Pausable {
    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 amount_
    ) internal virtual override {
        super._beforeTokenTransfer(from_, to_, amount_);

        require(
            !paused(),
            "ERC20Pausable: _beforeTokenTransfer - token transfer when paused."
        );
    }
}
