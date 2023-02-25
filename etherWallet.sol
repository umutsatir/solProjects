// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Wallet {
    address payable public immutable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    function withdraw(uint _amount) public {
        require(owner == msg.sender, "you are not the owner");
        require(getBalance() >= _amount, "insufficient balance");
        payable(msg.sender).transfer(_amount);
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}