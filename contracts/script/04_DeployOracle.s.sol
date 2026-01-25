// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {MockOracle} from "../src/MockOracle.sol";

contract DeployOracle is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MockOracle oracle = new MockOracle();
        console.log("MockOracle deployed to:", address(oracle));

        vm.stopBroadcast();
    }
}
