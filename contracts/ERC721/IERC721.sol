// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC165.sol";

interface IERC721 is IERC165 {
    function balanceOf(address owner_) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId_) external returns (address owner);

    function approve(address spender_, uint256 tokenId_) external;

    function getApproved(uint256 tokenId_)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator_, bool approved_) external;

    function isApprovedForAll(address owner_, address operator_)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId_
    ) external;

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId_,
        bytes calldata data_
    ) external;
}
