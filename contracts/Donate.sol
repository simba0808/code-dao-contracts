// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Donate {
    address public owner;
    address public treasuryAddress;
    uint256 public minDonationAmount;

    mapping(address => uint256) public donations;
    mapping(address => uint256) public donorLvls;

    event Donated(address indexed donor, uint256 amount);
    event FundsWithdrawn(address indexed owner, uint256 amount);
    event TreasuryUpdated(address indexed treasury);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(address _treasuryAddress, uint256 _minDonationAmount) {
        owner = msg.sender;
        treasuryAddress = _treasuryAddress;
        minDonationAmount = _minDonationAmount;
    }

    function donate() public payable {
        require(msg.value >= minDonationAmount, "Donation amount too small");
        donations[msg.sender] += msg.value;
        payable(treasuryAddress).transfer(msg.value);

        emit Donated(msg.sender, msg.value);
    }

    function setTreasuryAddress(address _treasuryAddress) public onlyOwner {
        require(
            treasuryAddress != _treasuryAddress &&
                _treasuryAddress != address(0)
        );
        treasuryAddress = _treasuryAddress;

        emit TreasuryUpdated(_treasuryAddress);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
