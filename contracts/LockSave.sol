// SPDX-License-Identifier: MIT

import "./common/Modifiers.sol";

pragma solidity ^0.8.1;

contract LockSave is Modifiers {
    struct Saving {
        address owner;
        uint256 amount;
        uint256 timestamp;
        uint256 withdrawTimestamp;
    }

    mapping(address => Saving[]) Users;

    uint256 totalLockTokenRewards = 200000 * 10**18;

    /**
     *@dev Gets the total rewards left to be distributed
     */
    function getTotalRewardsLeft() public view returns (uint256) {
        return totalLockTokenRewards;
    }

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
    function getUserTotalSavingAmount(address _user)
        public
        view
        checkSenderExists
        returns (uint256)
    {
        uint256 total = 0;
        address owner = _user;

        // Get the user savings
        for (uint256 i = 0; i < Users[owner].length; i++) {
            total += Users[owner][i].amount;
        }

        return total;
    }

    /**
     * @dev Get the user savings list
     */
    function getUserSavings(address _user)
        public
        view
        checkSenderExists
        returns (Saving[] memory)
    {
        address owner = _user;
        return Users[owner];
    }

    /**
     * @dev Get the saving timestamp of the saving
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
     * @dev Get the withdrawal timestamp of the saving
     * @param _savingTimestamp Timestamp of the saving
     */
    function getWithdrawalTimestamp(uint256 _savingTimestamp)
        public
        view
        checkSenderExists
        returns (uint256)
    {
        address owner = msg.sender;

        for (uint256 i = 0; i < Users[owner].length; i++) {
            Saving memory _saving = Users[owner][i];
            if (_saving.timestamp == _savingTimestamp) {
                return _saving.withdrawTimestamp;
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
    {
        uint256 _withdrawTimestamp = getWithdrawalTimestamp(_savingTimestamp);
        if (block.timestamp >= _withdrawTimestamp) {
            withdrawOnTime(_savingTimestamp);
        } else {
            earlySavingsWithdrawal(_savingTimestamp);
        }
    }

    function withdrawOnTime(uint256 _savingTimestamp) public checkSenderExists {
        address payable owner = payable(msg.sender);
        uint256 amount = getSavingAmountByTimestamp(_savingTimestamp);

        bool sent = owner.send(amount);

        uint256 savingIndex = getSavingIndexByTimestamp(_savingTimestamp);
        delete Users[owner][savingIndex];
        require(sent, "Failed to withdraw");
    }

    /**
     * @dev Withdraw savings before withdrwal timestamp
     * @param _savingTimestamp Timestamp of the saving
     */
    function earlySavingsWithdrawal(uint256 _savingTimestamp)
        public
        checkSenderExists
    {
        address payable owner = payable(msg.sender);
        uint256 amount = getSavingAmountByTimestamp(_savingTimestamp);

        // Deduct 1% of the amount for an early withdrawal
        uint256 amountToDeduct = amount / 100;
        uint256 amountToSend = amount - amountToDeduct;

        bool sent = owner.send(amountToSend);

        uint256 savingIndex = getSavingIndexByTimestamp(_savingTimestamp);
        delete Users[owner][savingIndex];
        require(sent, "Failed to withdraw");
    }
}
