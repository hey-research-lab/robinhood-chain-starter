// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IMulticall3, MULTICALL3} from "../src/IMulticall3.sol";

interface IERC20Metadata {
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

/// @notice Read-only fork test against Robinhood Chain mainnet. It sends no transaction.
/// Skipped unless RUN_FORK_TESTS=true, so CI never depends on a public RPC:
///   RUN_FORK_TESTS=true forge test --match-path test/Multicall3.fork.t.sol -vv
contract Multicall3ForkTest is Test {
    // WETH on Robinhood Chain, from docs.robinhood.com/chain/contracts
    address internal constant WETH = 0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73;

    function setUp() public {
        if (!vm.envOr("RUN_FORK_TESTS", false)) {
            vm.skip(true);
            return;
        }
        vm.createSelectFork("robinhood");
    }

    function test_Multicall3IsDeployed() public view {
        assertGt(MULTICALL3.code.length, 0, "no code at Multicall3");
        assertEq(IMulticall3(MULTICALL3).getChainId(), 4663);
    }

    function test_BatchedReadOfWeth() public {
        IMulticall3.Call3[] memory calls = new IMulticall3.Call3[](2);
        calls[0] = IMulticall3.Call3(WETH, false, abi.encodeCall(IERC20Metadata.symbol, ()));
        calls[1] = IMulticall3.Call3(WETH, false, abi.encodeCall(IERC20Metadata.decimals, ()));

        IMulticall3.Result[] memory results = IMulticall3(MULTICALL3).aggregate3(calls);

        assertEq(abi.decode(results[0].returnData, (string)), "WETH");
        assertEq(abi.decode(results[1].returnData, (uint8)), 18);
    }
}
