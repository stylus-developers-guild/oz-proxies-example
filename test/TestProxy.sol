 // SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";

import {SLOT_LOGIC, Proxy} from "../src/Proxy.sol";

interface IArbFoundry {
    function deployStylusCode(string calldata artifact) external returns (address);
}

interface IProxy {
    function upgradeToAndCall(address newImpl, bytes memory data) external;
}

interface IHello {
    function hello() external returns (string memory);
}

contract TestErc20 {
    bool public wasSpent;
    function transferFrom(address, address, uint256) external returns (bool) {
        wasSpent = true;
        return true;
    }
}

contract World {
    function world() external returns (string memory) {
        return "World!";
    }

    function proxiableUUID() external returns (bytes32) {
        return SLOT_LOGIC;
    }
}

contract TestProxy is Test {
    TestErc20 erc20;
    address impl;
    Proxy proxy;
    address impl2;

    function setUp() public {
        erc20 = new TestErc20();
        impl = IArbFoundry(address(vm)).deployStylusCode("oz-proxies.wasm");
        proxy = new Proxy(address(this), address(this), address(erc20), 1e6, impl);
        impl2 = address(new World());
    }

    function testImpl() public {
        assertNotEq(address(0), impl);
        assertEq("Hello!", IHello(impl).hello());
    }

    function testProxy() public {
        assert(!erc20.wasSpent());
        assertEq("Hello!", IHello(address(proxy)).hello());
        assert(erc20.wasSpent());
        IProxy(address(proxy)).upgradeToAndCall(impl2, "");
        assertEq("World!", World(address(proxy)).world());
    }
}
