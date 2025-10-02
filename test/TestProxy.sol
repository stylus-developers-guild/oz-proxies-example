 // SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";

import "../src/Proxy.sol";

interface IArbOS {
    function deployStylusCode(string calldata artifact) external returns (address);
}

interface IHello {
    function hello() external pure returns (string memory);
}

contract TestErc20 {
    bool public wasSpent;
    function transferFrom(address, address, uint256) external returns (bool) {
        wasSpent = true;
        return true;
    }
}

contract TestProxy is Test {
    TestErc20 erc20;
    address impl;
    Proxy proxy;

    function setUp() public {
        erc20 = new TestErc20();
        impl = IArbOS(address(vm)).deployStylusCode("oz-proxies.wasm");
        proxy = new Proxy(address(this), address(this), address(erc20), 1e6, impl);
    }

    function testSomething() public view {
        assertNotEq(address(0), impl);
        assertEq("Hello", IHello(impl).hello());
    }
}
