// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice The subset of Multicall3 (github.com/mds1/multicall3) this starter uses.
/// Deployed at the same address on Robinhood Chain as on most EVM chains.
interface IMulticall3 {
    struct Call3 {
        address target;
        bool allowFailure;
        bytes callData;
    }

    struct Result {
        bool success;
        bytes returnData;
    }

    function aggregate3(Call3[] calldata calls)
        external
        payable
        returns (Result[] memory returnData);

    function getChainId() external view returns (uint256 chainid);
}

address constant MULTICALL3 = 0xcA11bde05977b3631167028862bE2a173976CA11;
