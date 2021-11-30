// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LockToken is ERC20 {
    address private admin;

    constructor() ERC20("Lock", "LOCK") {
        _mint(msg.sender, 1000000000 * 10 ** 18);
        admin = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == admin);
        _;
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    function destroy(uint256 _amount) public onlyOwner {
        _burn(msg.sender, _amount);
    }

    function crowdSales(uint256 _amount) public payable onlyOwner {
        _transfer(admin, msg.sender, _amount);
    }
}
