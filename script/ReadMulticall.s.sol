// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {IMulticall3, MULTICALL3} from "../src/IMulticall3.sol";

interface IERC20Metadata {
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
}

/// @notice Read-only: batches six token reads into one Multicall3 call. Never broadcasts.
///   forge script script/ReadMulticall.s.sol --rpc-url robinhood
contract ReadMulticall is Script {
    // From docs.robinhood.com/chain/contracts
    address internal constant WETH = 0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73;
    address internal constant USDG = 0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168;

    function run() external {
        address[2] memory tokens = [WETH, USDG];
        IMulticall3.Call3[] memory calls = new IMulticall3.Call3[](6);
        for (uint256 i = 0; i < tokens.length; i++) {
            calls[i * 3] =
                IMulticall3.Call3(tokens[i], true, abi.encodeCall(IERC20Metadata.symbol, ()));
            calls[i * 3 + 1] =
                IMulticall3.Call3(tokens[i], true, abi.encodeCall(IERC20Metadata.decimals, ()));
            calls[i * 3 + 2] =
                IMulticall3.Call3(tokens[i], true, abi.encodeCall(IERC20Metadata.totalSupply, ()));
        }

        IMulticall3.Result[] memory r = IMulticall3(MULTICALL3).aggregate3(calls);

        console.log("chain id", block.chainid);
        for (uint256 i = 0; i < tokens.length; i++) {
            if (!r[i * 3].success || !r[i * 3 + 1].success || !r[i * 3 + 2].success) {
                console.log("read failed for", tokens[i]);
                continue;
            }
            console.log(abi.decode(r[i * 3].returnData, (string)), tokens[i]);
            console.log("  decimals", abi.decode(r[i * 3 + 1].returnData, (uint8)));
            console.log("  totalSupply (raw)", abi.decode(r[i * 3 + 2].returnData, (uint256)));
        }
    }
}
