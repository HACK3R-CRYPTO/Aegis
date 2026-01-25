// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {
    BeforeSwapDelta,
    BeforeSwapDeltaLibrary
} from "v4-core/src/types/BeforeSwapDelta.sol";
import {SwapParams} from "v4-core/src/types/PoolOperation.sol";

contract AegisHook is BaseHook {
    using BeforeSwapDeltaLibrary for BeforeSwapDelta;

    bool public panicMode;
    address public reactiveSentinel;
    address public owner;

    event PanicModeUpdated(bool status);
    error OnlySentinel();
    error PoolPaused();

    constructor(
        IPoolManager _poolManager,
        address _owner
    ) BaseHook(_poolManager) {
        owner = _owner;
    }

    modifier onlySentinelOrOwner() {
        if (msg.sender != reactiveSentinel && msg.sender != owner)
            revert OnlySentinel();
        _;
    }

    function setSentinel(address _sentinel) external {
        if (msg.sender != owner) revert OnlySentinel();
        reactiveSentinel = _sentinel;
    }

    function setPanicMode(bool _status) external onlySentinelOrOwner {
        panicMode = _status;
        emit PanicModeUpdated(_status);
    }

    function getHookPermissions()
        public
        pure
        override
        returns (Hooks.Permissions memory)
    {
        return
            Hooks.Permissions({
                beforeInitialize: false,
                afterInitialize: false,
                beforeAddLiquidity: false,
                afterAddLiquidity: false,
                beforeRemoveLiquidity: false,
                afterRemoveLiquidity: false,
                beforeSwap: true, // Enabled
                afterSwap: false,
                beforeDonate: false,
                afterDonate: false,
                beforeSwapReturnDelta: false,
                afterSwapReturnDelta: false,
                afterAddLiquidityReturnDelta: false,
                afterRemoveLiquidityReturnDelta: false
            });
    }

    // Override the INTERNAL function _beforeSwap, not the external one
    function _beforeSwap(
        address,
        PoolKey calldata,
        SwapParams calldata,
        bytes calldata
    ) internal view override returns (bytes4, BeforeSwapDelta, uint24) {
        if (panicMode) {
            revert PoolPaused();
        }
        return (
            BaseHook.beforeSwap.selector,
            BeforeSwapDeltaLibrary.ZERO_DELTA,
            0
        );
    }
}
