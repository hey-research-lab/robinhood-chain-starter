// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

/// @notice Deploys Counter. Holds no key: the signer comes from the command line.
///   Dry run (no transaction):  forge script script/Deploy.s.sol --rpc-url robinhood
///   Broadcast:                 add --broadcast --account <keystore-name>
contract Deploy is Script {
    function run() external returns (Counter counter) {
        vm.startBroadcast();
        counter = new Counter();
        vm.stopBroadcast();

        console.log("Counter deployed at", address(counter));
        console.log("Chain id", block.chainid);
    }
}
