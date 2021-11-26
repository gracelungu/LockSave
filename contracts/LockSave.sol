// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

contract LockSave {
    struct Saving {
        address owner;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Saving[]) Users;

    /**
     * @dev Validate received amount
     * @param _amount Amount to save
     */
    modifier validateAmount(uint256 _amount) {
        require(_amount <= 0, "Amount must be greater than 0");
        _;
    }

    /**
     * @dev Create new user saving
     * @param _owner Owner of the saving
     * @param _amount Amount to save
     */
    function _createSaving(address _owner, uint256 _amount)
        private
        validateAmount(_amount)
    {
        // The user should not exist
        assert(Users[_owner].length == 0);

        // Add the new user saving
        Users[_owner][0] = Saving(_owner, _amount, block.timestamp);
    }

    /**
     *@dev Add new saving to existing user
     *@param _owner Owner of the saving
     *@param _amount Amount to save
     */
    function _addSaving(address _owner, uint256 _amount)
        private
        validateAmount(_amount)
    {
        // The user should exist
        assert(Users[_owner].length != 0);

        // Add the new saving to the already existing user
        Users[_owner].push(Saving(_owner, _amount, block.timestamp));
    }

    /**
     * @dev Receive savings from user
     */
    function receiveSavings() public payable {
        address owner = msg.sender;
        uint256 amount = msg.value;

        // Check if the user already exists
        if (Users[owner].length == 0) {
            // Create new user saving
            _createSaving(owner, amount);
        } else {
            // Add new saving to existing user
            _addSaving(owner, amount);
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
}
