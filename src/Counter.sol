// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Counter
/// @notice The smallest useful contract: a number anyone can set or increment.
contract Counter {
    uint256 public number;

    event NumberChanged(address indexed by, uint256 newNumber);

    function setNumber(uint256 newNumber) external {
        number = newNumber;
        emit NumberChanged(msg.sender, newNumber);
    }

    function increment() external {
        number += 1;
        emit NumberChanged(msg.sender, number);
    }
}
