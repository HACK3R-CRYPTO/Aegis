// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {PoolManager} from "v4-core/src/PoolManager.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {HookMiner} from "v4-periphery/src/utils/HookMiner.sol";
import {AegisHook} from "../src/AegisHook.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";

contract DeployHook is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Unichain Testnet PoolManager (Check docs for official address, using placeholder or deploying new if needed)
        // For hackathon v4 template usually requires deploying manager or using canonical
        IPoolManager manager = IPoolManager(
            0x00000000000444de76E3D23D922DeC284999ea16
        ); // Canonical v4 address on some testnets, verify for Unichain

        // Mine a salt for the hook to get flags: BEFORE_SWAP_FLAG = 1 << 7 = 128
        uint160 flags = uint160(Hooks.BEFORE_SWAP_FLAG);
        (address hookAddress, bytes32 salt) = HookMiner.find(
            address(this),
            flags,
            type(AegisHook).creationCode,
            abi.encode(address(manager), msg.sender)
        );

        AegisHook hook = new AegisHook{salt: salt}(manager, msg.sender);
        console.log("AegisHook deployed to:", address(hook));

        vm.stopBroadcast();
    }
}
