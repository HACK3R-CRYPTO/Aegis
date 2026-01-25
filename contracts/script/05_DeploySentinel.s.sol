// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {AegisSentinel} from "../src/AegisSentinel.sol";

contract DeploySentinel is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // CONFIGURATION
        address REACTIVE_SYSTEM_SERVICE = 0xc7203561ef179333005A92812A53d9142dD9d47F; // Kopli Testnet Service
        address AEGIS_HOOK = vm.envAddress("AEGIS_HOOK_ADDRESS"); // Get from Unichain deployment
        address MOCK_ORACLE = vm.envAddress("MOCK_ORACLE_ADDRESS"); // Get from Sepolia deployment

        AegisSentinel sentinel = new AegisSentinel(
            REACTIVE_SYSTEM_SERVICE,
            AEGIS_HOOK,
            MOCK_ORACLE
        );
        console.log("AegisSentinel deployed to:", address(sentinel));

        vm.stopBroadcast();
    }
}
