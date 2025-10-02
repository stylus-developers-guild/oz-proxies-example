// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

bytes32 constant SLOT_LOGIC = bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1);

interface IImpl {
    function init(
        address owner,
        address feeCollector,
        address token,
        uint256 tokenAmount
    ) external;
}

interface IERC20 {
    function transferFrom(address owner, address spender, uint256 amount) external returns (bool);
}

contract Proxy {
    address private feeCollector;
    IERC20 private token;
    uint256 private feeAmount;

    event TollPaid(
        address indexed payer,
        uint256 indexed amount
    );

    constructor(
        address _owner,
        address _feeCollector,
        address _token,
        uint256 _feeAmount,
        address _impl
    ) {
        bytes32 slot = SLOT_LOGIC;
        assembly {
            sstore(slot, _impl)
        }
        (bool success,) = _impl.delegatecall(abi.encodePacked(
            IImpl.init.selector,
            _owner,
            _feeCollector,
            _token,
            _feeAmount
        ));
        require(success);
    }

    fallback() external {
        address impl;
        bytes32 slot = SLOT_LOGIC;
        assembly {
            impl := sload(slot)
        }
        require(token.transferFrom(msg.sender, address(this), feeAmount));
        emit TollPaid(msg.sender, feeAmount);
        (bool success, bytes memory rd) = impl.delegatecall(msg.data);
        if (!success) {
            assembly {
                revert(add(rd, 32), mload(rd))
            }
        }
    }
}
