// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "../Common/Context.sol";

contract ERC20 is IERC20, IERC20Metadata, Context {
    uint256 private _totalSupply;
    uint256 private _decimals;

    string private _name;
    string private _symbol;

    event BeforeTokenTransfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event AfterTokenTransfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    constructor(
        uint256 initialSupply_,
        uint256 decimals_,
        string memory name_,
        string memory symbol_
    ) {
        _mint(_msgSender(), initialSupply_);

        _decimals = decimals_;
        _name = name_;
        _symbol = symbol_;
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 amount_
    ) internal virtual {
        emit BeforeTokenTransfer(from_, to_, amount_);
    }

    function _afterTokenTransfer(
        address from_,
        address to_,
        uint256 amount_
    ) internal virtual {
        emit AfterTokenTransfer(from_, to_, amount_);
    }

    function _mint(address to_, uint256 amount_) internal virtual {
        require(to_ != address(0), "ERC20: mint with to_ = zero address.");

        _beforeTokenTransfer(address(0), to_, amount_);

        _totalSupply = _totalSupply + amount_;

        unchecked {
            // Overflow is checked by default above, when computing _totalSupply
            _balances[to_] = _balances[to_] + amount_;
        }

        emit Transfer(address(0), to_, amount_);

        _afterTokenTransfer(address(0), to_, amount_);
    }

    function _burn(address account_, uint256 amount_) internal virtual {
        require(
            account_ != address(0),
            "ERC20: _burn with account_ = zero address."
        );

        _beforeTokenTransfer(account_, address(0), amount_);

        uint256 accountBalance = _balances[account_];
        require(
            accountBalance >= amount_,
            "ERC20: _burn with amount_ > balance in account_."
        );
        unchecked {
            // Since we check for underflow above
            _balances[account_] = _balances[account_] - amount_;
            _totalSupply = _totalSupply - amount_;
        }

        emit Transfer(account_, address(0), amount_);

        _afterTokenTransfer(account_, address(0), amount_);
    }

    function _transfer(
        address from_,
        address to_,
        uint256 amount_
    ) internal virtual {
        require(
            from_ != address(0),
            "ERC20: _transfer with from_ = zero address."
        );
        require(to_ != address(0), "ERC20: _transfer with to_ = zero address.");
        require(amount_ != 0, "ERC20: _transfer with amount_ = zero.");

        _beforeTokenTransfer(from_, to_, amount_);

        require(
            _balances[from_] >= amount_,
            "ERC20: transfer amount exceeds balance."
        );

        unchecked {
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[from_] = _balances[from_] - amount_;
            _balances[to_] = _balances[to_] + amount_;
        }

        emit Transfer(from_, to_, amount_);

        _afterTokenTransfer(from_, to_, amount_);
    }

    function _approve(
        address owner_,
        address spender_,
        uint256 amount_
    ) internal virtual {
        require(
            owner_ != address(0),
            "ERC20: _approve with owner_ = zero address."
        );
        require(
            spender_ != address(0),
            "ERC20: _approve with spender_ = zero address."
        );

        _allowances[owner_][spender_] = amount_;

        emit Approval(owner_, spender_, amount_);
    }

    function _spendAllowance(
        address owner_,
        address spender_,
        uint256 amount_
    ) internal virtual {
        uint256 currentAllowance = allowance(owner_, spender_);
        require(
            amount_ <= currentAllowance,
            "ERC20: _spendAllowance allowance smaller than amount."
        );
        unchecked {
            // We checked above that currentAllowance - amount_ doesn't underflow
            _approve(owner_, spender_, currentAllowance - amount_);
        }
    }

    function decimals() external view override returns (uint256) {
        return _decimals;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account_)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account_];
    }

    function transfer(address to_, uint256 amount_)
        external
        virtual
        override
        returns (bool)
    {
        address from = _msgSender();

        _transfer(from, to_, amount_);

        return true;
    }

    function allowance(address owner_, address spender_)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(owner_ != address(0), "ERC20: allowance from zero address.");
        require(spender_ != address(0), "ERC20: allowance to zero address.");

        return _allowances[owner_][spender_];
    }

    function approve(address spender_, uint256 amount_)
        external
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();

        _approve(owner, spender_, amount_);

        return true;
    }

    function transferFrom(
        address from_,
        address to_,
        uint256 amount_
    ) external virtual override returns (bool) {
        require(amount_ != 0, "ERC20: transferFrom with amount_ = zero.");
        require(to_ != address(0), "ERC20: transferFrom with to_ = zero.");

        address spender = _msgSender();
        _spendAllowance(from_, spender, amount_);
        _transfer(from_, to_, amount_);

        return true;
    }
}
