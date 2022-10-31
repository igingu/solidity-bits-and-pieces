// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract A {
    uint256 _randomUint;

    constructor(uint256 randomUint_) {
        _randomUint = randomUint_;
    }

    event EventA();

    function notVirtual() public virtual returns (string memory) {
        emit EventA();
        return "A notVirtual().";
    }
}

contract B is A(10) {
    event EventB();

    function notVirtual() public override returns (string memory) {
        super.notVirtual();
        emit EventB();
        return "B notVirtual().";
    }
}

// -----------------------------------------------------------

contract E {
    // This event will be used to trace function calls.
    event Log(string message);

    function foo() public virtual {
        emit Log("E.foo");
    }

    function bar() public virtual {
        emit Log("E.bar");
    }
}

contract F is E {
    function foo() public virtual override {
        emit Log("F.foo");
        E.foo();
    }

    function bar() public virtual override {
        emit Log("F.bar");
        super.bar();
    }
}

contract G is E {
    function foo() public virtual override {
        emit Log("G.foo");
        E.foo();
    }

    function bar() public virtual override {
        emit Log("G.bar");
        super.bar();
    }
}

contract H is F, G {
    function foo() public override(F, G) {
        // Calls G.foo() and then E.foo()
        // Inside F and G, E.foo() is called. Solidity is smart enough
        // to not call E.foo() twice. Hence E.foo() is only called by G.foo().
        super.foo();
    }

    function bar() public override(F, G) {
        // Write your code here
    }
}

contract I is G {
    function foo() public virtual override {
        emit Log("I.foo");
        G.foo();
    }

    function bar() public virtual override {
        emit Log("I.bar");
        super.bar();
    }
}

// -----------------------------------------------------------

// Call function with key-value inputs
contract XYZ {
    function someFuncWithManyInputs(
        uint x,
        uint y,
        uint z,
        address a,
        bool b,
        string memory c
    ) public pure returns (uint) {}

    function callFunc() external pure returns (uint) {
        return someFuncWithManyInputs(1, 2, 3, address(0), true, "c");
    }

    function callFuncWithKeyValue() external pure returns (uint) {
        return
            someFuncWithManyInputs({a: address(0), b: true, c: "", x: 1, y: 2, z: 3});
    }
}

// /* Graph of inheritance
//     A
//    / \
//   B   C
//  / \ /
// F  D,E

// */

// contract A {
//     function foo() public pure virtual returns (string memory) {
//         return "A";
//     }
// }

// // Contracts inherit other contracts by using the keyword 'is'.
// contract B is A {
//     // Override A.foo()
//     function foo() public pure virtual override returns (string memory) {
//         return "B";
//     }
// }

// contract C is A {
//     // Override A.foo()
//     function foo() public pure virtual override returns (string memory) {
//         return "C";
//     }
// }

// // Contracts can inherit from multiple parent contracts.
// // When a function is called that is defined multiple times in
// // different contracts, parent contracts are searched from
// // right to left, and in depth-first manner.

// contract D is B, C {
//     // D.foo() returns "C"
//     // since C is the right most parent contract with function foo()
//     function foo() public pure override(B, C) returns (string memory) {
//         return super.foo();
//     }
// }

// contract E is C, B {
//     // E.foo() returns "B"
//     // since B is the right most parent contract with function foo()
//     function foo() public pure override(C, B) returns (string memory) {
//         return super.foo();
//     }
// }

// // Inheritance must be ordered from “most base-like” to “most derived”.
// // Swapping the order of A and B will throw a compilation error.
// contract F is A, B {
//     function foo() public pure override(A, B) returns (string memory) {
//         return super.foo();
//     }
// }