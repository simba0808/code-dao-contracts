// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Donate {
    address public owner;
    address public treasury_address;
    uint256 public min_donation_amount;

    mapping(address => uint256) public donations;

    event Donated(address indexed donor, uint256 amount);
    event FundsWithdrawn(address indexed owner, uint256 amount);
    event TreasuryUpdated(address indexed treasury);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(address _treasury_address, uint256 _min_donation_amount) {
        owner = msg.sender;
        treasury_address = _treasury_address;
        min_donation_amount = _min_donation_amount;
    }

    function donate() public payable {
        require(msg.value >= min_donation_amount, "Donation amount too small");
        donations[msg.sender] += msg.value;
        payable(treasury_address).transfer(msg.value);

        emit Donated(msg.sender, msg.value);
    }

    function setTreasuryAddress(address _treasury_address) public onlyOwner {
        require(
            treasury_address != _treasury_address &&
                _treasury_address != address(0)
        );
        treasury_address = _treasury_address;

        emit TreasuryUpdated(_treasury_address);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
