// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contract to execute transactions sent, only if confirmed by a certain amount of users.
contract EtherMultiSigWallet {
    struct Transaction {
        uint256 value;
        bytes data;
        address to;
        uint16 numConfirmations;
        bool executed;
    }

    address[] private _owners;
    mapping(address => bool) private _isOwner;
    uint16 immutable _numConfirmationsRequired;

    mapping(uint256 => mapping(address => bool)) _transactionConfirmations;

    Transaction[] private _transactions;

    event TransactionSubmitted(
        uint256 indexed txIndex,
        address indexed from,
        uint256 value,
        bytes data,
        address indexed to
    );
    event TransactionConfirmed(uint256 indexed txIndex, address indexed by);
    event TransactionUnconfirmed(uint256 indexed txIndex, address indexed by);
    event TransactionExecuted(uint256 indexed txIndex, address indexed by);

    modifier onlyOwner() {
        require(
            _isOwner[msg.sender],
            "EtherMultiSigWallet: onlyOwner modifier."
        );
        _;
    }

    modifier txExists(uint256 txIndex) {
        require(
            txIndex < _transactions.length,
            "EtherMultiSigWallet: txExists modifier."
        );
        _;
    }

    modifier confirmed(uint256 txIndex, address account) {
        require(
            _transactionConfirmations[txIndex][account],
            "EtherMultiSigWallet: modifier confirmed."
        );
        _;
    }

    modifier notConfirmed(uint256 txIndex, address account) {
        require(
            !_transactionConfirmations[txIndex][account],
            "EtherMultiSigWallet: modifier notConfirmed."
        );
        _;
    }

    modifier enoughConfirmations(uint256 txIndex) {
        require(
            _transactions[txIndex].numConfirmations >=
                _numConfirmationsRequired,
            "EtherMultiSigWallet: enoughConfirmations modifier."
        );
        _;
    }

    modifier notExecuted(uint256 txIndex) {
        require(
            !_transactions[txIndex].executed,
            "EtherMultiSigWallet: modifier notExecuted."
        );
        _;
    }

    constructor(address[] memory owners_, uint16 numConfirmationsRequired_) {
        uint256 numOwners = owners_.length;

        require(
            numOwners > 0,
            "EtherMultiSigWallet: constructor with no owners."
        );
        require(
            0 < numConfirmationsRequired_ &&
                numConfirmationsRequired_ <= numOwners,
            "EtherMultiSigWallet: constructor with invalid number of confirmations."
        );

        for (uint256 i = 0; i < numOwners; ++i) {
            address newOwner = owners_[i];
            require(
                !_isOwner[newOwner],
                "EtherMultiSigWallet: constructor with duplicate owners."
            );
            _owners.push(newOwner);
            _isOwner[newOwner] = true;
        }

        _numConfirmationsRequired = numConfirmationsRequired_;
    }

    function submitTransaction(
        uint256 value_,
        bytes calldata data_,
        address to_
    ) external onlyOwner {
        _transactions.push(Transaction(value_, data_, to_, 0, false));

        emit TransactionSubmitted(
            _transactions.length - 1,
            msg.sender,
            value_,
            data_,
            to_
        );
    }

    function confirmTransaction(uint256 txIndex)
        external
        onlyOwner
        txExists(txIndex)
        notConfirmed(txIndex, msg.sender)
        notExecuted(txIndex)
    {
        unchecked {
            _transactions[txIndex].numConfirmations++;
        }

        _transactionConfirmations[txIndex][msg.sender] = true;

        emit TransactionConfirmed(txIndex, msg.sender);
    }

    function unconfirmTransaction(uint256 txIndex)
        external
        onlyOwner
        txExists(txIndex)
        confirmed(txIndex, msg.sender)
        notExecuted(txIndex)
    {
        unchecked {
            _transactions[txIndex].numConfirmations--;
        }

        delete _transactionConfirmations[txIndex][msg.sender];
        emit TransactionUnconfirmed(txIndex, msg.sender);
    }

    function executeTransaction(uint256 txIndex)
        external
        onlyOwner
        txExists(txIndex)
        enoughConfirmations(txIndex)
        notExecuted(txIndex)
    {
        Transaction storage transaction = _transactions[txIndex];

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "EtherMultiSigWallet: executeTransaction modifier.");

        emit TransactionExecuted(txIndex, msg.sender);
    }

    function getOwners() external view onlyOwner returns (address[] memory) {
        return _owners;
    }

    function getTransactions()
        external
        view
        onlyOwner
        returns (Transaction[] memory)
    {
        return _transactions;
    }

    function getTransactionCount() external view onlyOwner returns (uint256) {
        return _transactions.length;
    }

    function getTransaction(uint256 txIndex)
        external
        view
        onlyOwner
        txExists(txIndex)
        returns (Transaction memory)
    {
        return _transactions[txIndex];
    }
}

contract Callee {
    function myFunction(uint256 value, bool b)
        external
        pure
        returns (
            uint128,
            bool,
            string memory,
            bytes memory
        )
    {
        string memory returnValue = "ReturnValue";
        return (uint128(value), !b, returnValue, bytes(returnValue));
    }
}

contract Caller {
    EtherMultiSigWallet private _etherMultiSigWallet;
    Callee private _callee;

    event EtherMultiSigWalletCreated(address indexed walletAddress);
    event CalleeCreated(address indexed calleeAddress);

    constructor() {
        address[] memory owners = new address[](3);
        owners[0] = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        owners[1] = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        owners[2] = address(this);

        _etherMultiSigWallet = new EtherMultiSigWallet(owners, 2);
        emit EtherMultiSigWalletCreated(address(_etherMultiSigWallet));

        _callee = new Callee();
        emit CalleeCreated(address(_callee));
    }

    function submitWithEncodeWithSignature(uint256 value, bool b) external {
        bytes memory data = abi.encodeWithSignature(
            "myFunction(uint256,bool)",
            value,
            b
        );
        _etherMultiSigWallet.submitTransaction(1 ether, data, address(_callee));
    }

    function submitWithEncodeWithSelector(uint256 value, bool b) external {
        bytes memory data = abi.encodeWithSelector(
            Callee.myFunction.selector,
            value,
            b
        );
        _etherMultiSigWallet.submitTransaction(1 ether, data, address(_callee));
    }

    function submitWithEncodeCall(uint256 value, bool b) external {
        bytes memory data = abi.encodeCall(Callee.myFunction, (value, b));
        _etherMultiSigWallet.submitTransaction(1 ether, data, address(_callee));
    }
}
