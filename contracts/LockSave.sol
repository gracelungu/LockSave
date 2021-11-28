// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

contract LockSave {
    struct Saving {
        address owner;
        uint256 amount;
        uint256 timestamp;
        uint256 withdrawTimestamp;
    }

    mapping(address => Saving[]) Users;

    /**
     * @dev Check if sender already exist
     */
    modifier checkSenderExists() {
        if (Users[msg.sender].length == 0) {
            revert("User not found");
        }
        _;
    }

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

    /**
     * @dev Receive savings from user
     * @param _withdrawTimestamp Timestamp of the withdrawal
     */
    function receiveSavings(uint256 _withdrawTimestamp)
        public
        payable
        validateAmount
    {
        address owner = msg.sender;
        uint256 amount = msg.value;

        Saving memory saving = Saving(
            owner,
            amount,
            block.timestamp,
            _withdrawTimestamp
        );

        // Add the new saving
        Users[owner].push(saving);
    }

    /**
     * @dev Get the total amount of savings
     */
    function getUserTotalSavingAmount()
        public
        view
        checkSenderExists
        returns (uint256)
    {
        uint256 total = 0;
        address owner = msg.sender;

        // Get the user savings
        for (uint256 i = 0; i < Users[owner].length; i++) {
            total += Users[owner][i].amount;
        }

        return total;
    }

    /**
     * @dev Get the withdrawal timestamp of the saving
     * @param _withdrawalTimestamp Timestamp of the saving
     */
    function getSavingTimestamp(uint256 _withdrawalTimestamp)
        public
        view
        checkSenderExists
        returns (uint256)
    {
        address owner = msg.sender;

        for (uint256 i = 0; i < Users[owner].length; i++) {
            Saving memory _saving = Users[owner][i];
            if (_saving.withdrawTimestamp == _withdrawalTimestamp) {
                return _saving.timestamp;
            }
        }

        revert("Saving not found");
    }

    /**
     * @dev Get the amount of a saving
     * @param _timestamp Timestamp of the saving
     */
    function getSavingAmountByTimestamp(uint256 _timestamp)
        public
        view
        checkSenderExists
        returns (uint256)
    {
        address owner = msg.sender;

        for (uint256 i = 0; i < Users[owner].length; i++) {
            Saving memory _saving = Users[owner][i];
            if (_saving.timestamp == _timestamp) {
                return _saving.amount;
            }
        }

        revert("Saving not found");
    }

    /**
     * @dev Get the index of the saving by timestamp
     * @param _timestamp Timestamp of the saving
     */
    function getSavingIndexByTimestamp(uint256 _timestamp)
        public
        view
        checkSenderExists
        returns (uint256)
    {
        address owner = msg.sender;

        for (uint256 i = 0; i < Users[owner].length; i++) {
            Saving memory _saving = Users[owner][i];
            if (_saving.timestamp == _timestamp) {
                return i;
            }
        }

        revert("Saving not found");
    }

    /**
     * @dev Withdraw savings
     * @param _savingTimestamp Timestamp of the saving
     */
    function withdrawSavings(uint256 _savingTimestamp)
        public
        checkSenderExists
        validateWithdrawTimestamp(_savingTimestamp)
    {
        address payable owner = payable(msg.sender);
        uint256 amount = getSavingAmountByTimestamp(_savingTimestamp);
        bool sent = owner.send(amount);
        uint256 savingIndex = getSavingIndexByTimestamp(_savingTimestamp);
        delete Users[owner][savingIndex];
        require(sent, "Failed to withdraw");
    }
}
