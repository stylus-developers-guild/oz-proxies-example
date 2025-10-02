 // SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";

contract TestErc20 {
    bool public wasSpent;
    function transferFrom(address, address, uint256) external returns (bool) {
        wasSpent = true;
    }
}

contract TestProxy is Test {
    TestErc20 erc20;
    address impl;
    address proxy;

    function setUp() public {
        erc20 = new TestErc20();
        impl = vm.deployStylusCode("oz-proxies.wasm");
    }
}
