// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";

contract ERC721 is IERC721 {
    mapping(address => uint256) private _balanceOf;

    mapping(uint256 => address) private _ownerOf;

    mapping(uint256 => address) private _approvals;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 tokenId
    );
    event ApprovalForAll(
        address indexed from,
        address indexed spender,
        bool approved
    );

    event Transfer(address indexed from, address indexed to, uint256 tokenId);

    modifier tokenExists(uint256 tokenId) {
        require(
            _ownerOf[tokenId] != address(0),
            "ERC721: tokenExists modifier."
        );
        _;
    }

    modifier isAllowed(uint256 tokenId) {
        require(
            msg.sender == _ownerOf[tokenId] ||
                msg.sender == _approvals[tokenId] ||
                isApprovedForAll[_ownerOf[tokenId]][msg.sender],
            "ERC721: isAllowed modifier."
        );
        _;
    }

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        returns (bool)
    {
        return
            interfaceID == type(IERC721).interfaceId ||
            interfaceID == type(IERC165).interfaceId;
    }

    function balanceOf(address owner_) external view returns (uint256 balance) {
        require(
            owner_ != address(0),
            "ERC721: balanceOf with owner_ = zero address."
        );
        return _balanceOf[owner_];
    }

    function ownerOf(uint256 tokenId_)
        external
        view
        tokenExists(tokenId_)
        returns (address owner)
    {
        return _ownerOf[tokenId_];
    }

    function approve(address spender_, uint256 tokenId_)
        external
        tokenExists(tokenId_)
        isAllowed(tokenId_)
    {
        require(
            spender_ != address(0),
            "ERC721: approve with to_ = zero address."
        );
        _approvals[tokenId_] = spender_;

        emit Approval(_ownerOf[tokenId_], spender_, tokenId_);
    }

    function getApproved(uint256 tokenId_)
        external
        view
        tokenExists(tokenId_)
        returns (address operator)
    {
        return _approvals[tokenId_];
    }

    function setApprovalForAll(address operator_, bool approved_) external {
        isApprovedForAll[msg.sender][operator_] = approved_;

        emit ApprovalForAll(msg.sender, operator_, approved_);
    }

    function transferFrom(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal tokenExists(tokenId_) isAllowed(tokenId_) {
        require(
            from_ != address(0),
            "ERC721: transferFrom with from_ = zero address."
        );
        require(
            from_ == _ownerOf[tokenId_],
            "ERC721: transferFrom with from_ != _ownerOf[tokenId_]."
        );
        require(
            to_ != address(0),
            "ERC721: transferFrom with to_ = zero address."
        );

        _ownerOf[tokenId_] = to_;
        delete _approvals[tokenId_];

        unchecked {
            _balanceOf[_ownerOf[tokenId_]]--;
            _balanceOf[to_]++;
        }

        emit Transfer(from_, to_, tokenId_);
    }

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId_
    ) external {
        transferFrom(from_, to_, tokenId_);

        require(
            to_.code.length == 0 ||
                IERC721Receiver(to_).onERC721Received(
                    msg.sender,
                    from_,
                    tokenId_,
                    ""
                ) ==
                IERC721Receiver.onERC721Received.selector,
            "ERC721: safeTransferFrom with unsafe recipient."
        );
    }

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId_,
        bytes calldata data_
    ) external {
        transferFrom(from_, to_, tokenId_);

        require(
            to_.code.length == 0 ||
                IERC721Receiver(to_).onERC721Received(
                    msg.sender,
                    to_,
                    tokenId_,
                    data_
                ) ==
                IERC721Receiver.onERC721Received.selector,
            "ERC721: safeTransferFrom with unsafe recipient."
        );
    }
}
