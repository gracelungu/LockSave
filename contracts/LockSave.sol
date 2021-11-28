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
     * @param _amount Amount to save
     */
    modifier validateAmount(uint256 _amount) {
        require(_amount <= 0, "Amount must be greater than 0");
        _;
    }

    /**
     * @dev Validate withdrawal amount
     * @param _amount Amount to withdrawn
     */
    modifier validateWithdrawAmount(uint256 _amount) {
        require(_amount <= 0, "Amount must be greater than 0");
        _;
    }

    /**
     * @dev Validate withdrawal timestamp
     * @param _withdrawTimestamp withdrawal timestamp
     */
    modifier validateWithdrawTimestamp(uint256 _withdrawTimestamp) {
        require(
            _withdrawTimestamp <= block.timestamp,
            "The saving period has not elapsed"
        );
        _;
    }

    /**
     * @dev Create new user saving
     * @param _owner Owner of the saving
     * @param _amount Amount to save
     * @param _withdrawTimestamp Timestamp of the withdrawal
     */
    function _createSaving(
        address _owner,
        uint256 _amount,
        uint256 _withdrawTimestamp
    ) private validateAmount(_amount) {
        // The user should not exist
        assert(Users[_owner].length == 0);

        // Add the new user saving
        Users[_owner][0] = Saving(
            _owner,
            _amount,
            block.timestamp,
            _withdrawTimestamp
        );
    }

    /**
     * @dev Add new saving to existing user
     * @param _owner Owner of the saving
     * @param _amount Amount to save
     * @param _withdrawTimestamp Timestamp of the withdrawal
     */
    function _addSaving(
        address _owner,
        uint256 _amount,
        uint256 _withdrawTimestamp
    ) private validateAmount(_amount) {
        // The user should exist
        assert(Users[_owner].length != 0);

        // Add the new saving to the already existing user
        Users[_owner].push(
            Saving(_owner, _amount, block.timestamp, _withdrawTimestamp)
        );
    }

    /**
     * @dev Receive savings from user
     * @param _withdrawTimestamp Timestamp of the withdrawal
     */
    function receiveSavings(uint256 _withdrawTimestamp)
        public
        payable
        validateAmount(msg.value)
    {
        address owner = msg.sender;
        uint256 amount = msg.value;

        // Check if the user already exists
        if (Users[owner].length == 0) {
            // Create new user saving
            _createSaving(owner, amount, _withdrawTimestamp);
        } else {
            // Add new saving to existing user
            _addSaving(owner, amount, _withdrawTimestamp);
        }
    }

    /**
     * @dev Get the total amount of savings
     * @return Total amount of savings
     */
    function getUserTotalSavingAmount(address _owner)
        public
        view
        returns (uint256)
    {
        uint256 total = 0;

        // Get the user savings
        for (uint256 i = 0; i < Users[_owner].length; i++) {
            total += Users[_owner][i].amount;
        }

        return total;
    }

    /**
     * @dev Get the withdrwal timestamp of the saving
     * @param _savingTimestamp Timestamp of the saving
     */
    function getWithdrwalTimestamp(uint256 _savingTimestamp)
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
     * @param _savingTimestamp Timestamp of the saving
     */
    function getSavingAmountByTimestamp(uint256 _savingTimestamp)
        public
        view
        checkSenderExists
        returns (uint256)
    {
        address owner = msg.sender;

        for (uint256 i = 0; i < Users[owner].length; i++) {
            Saving memory _saving = Users[owner][i];
            if (_saving.timestamp == _savingTimestamp) {
                return _saving.amount;
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
        require(sent, "Failed to withdraw");
    }
}
