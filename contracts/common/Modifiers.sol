// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

contract Modifiers {
    /**
     * @dev Validate received amount
     */
    modifier validateAmount() {
        require(msg.value > 0, "Amount must be greater than 0");
        _;
    }

    /**
     * @dev Validate withdrawal timestamp
     * @param _withdrawTimestamp withdrawal timestamp
     */
    modifier validateWithdrawTimestamp(uint256 _withdrawTimestamp) {
        require(
            block.timestamp >= _withdrawTimestamp,
            "The saving period has not elapsed"
        );
        _;
    }
}