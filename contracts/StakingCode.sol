// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract CodeStake is Ownable, ReentrancyGuard {
    struct Position {
        uint256 amount;
        uint256 createdAt;
        uint256 lockInPeriod;
        uint256 rewardRate;
        bool withdrawn;
    }

    IERC20 immutable codeToken;

    uint256 public totalStaked;

    mapping(address => Position[]) public positions;

    constructor(address _owner, address _tokenAddress) Ownable(_owner) {
        codeToken = IERC20(_tokenAddress);
    }

    function stake(uint256 _amount, uint256 _lockInPeriod) external {
        require(_amount > 0, "Amount must be greater than 0");

        uint256 rewardRate = _getRewardRate(_lockInPeriod);
        require(rewardRate > 0, "Invalid staking period");

        codeToken.transferFrom(msg.sender, address(this), _amount);

        positions[msg.sender].push(
            Position({
                amount: _amount,
                createdAt: block.timestamp,
                lockInPeriod: _lockInPeriod,
                rewardRate: rewardRate,
                withdrawn: false
            })
        );

        totalStaked += _amount;

        emit Staked(msg.sender, _amount, _lockInPeriod, rewardRate);
    }

    function unstake(uint256 amount) external {}

    function claimRewards() external {
        _updateRewards(msg.sender);
    }

    function cliamReward(uint256 _positionIndex) public {
        Position storage position = positions[msg.sender][_positionIndex];

        uint256 reward = _calculateReward(position);
    }

    function _updateRewards(address _user) internal {
        Position storage position = positions[_user];
        uint256 pendingReward = _calculateReward(_user);

        if (pendingReward > 0) {
            codeToken.transfer(_user, pendingReward);

            emit RewardClaimed(_user, pendingReward);
        }
    }

    function _calculateReward(
        Position memory positionData
    ) internal view returns (uint256) {
        if (positionData.withdrawn) return 0;

        uint256 stakingDuration = block.timestamp - positionData.createdAt;
        uint256 annualReward = (positionData.amount * positionData.rewardRate) / 100;
        uint256 reward = (annualReward * stakingDuration) / 365 days;

        return reward;
    }

    function _getRewardRate(
        uint256 _lockInPeriod
    ) internal pure returns (uint256) {
        if (_lockInPeriod == 7 days) return 3;
        if (_lockInPeriod == 30 days) return 5;
        if (_lockInPeriod == 180 days) return 8;
        if (_lockInPeriod == 365 days) return 10;
        if (_lockInPeriod == 1095 days) return 12;
        return 0;
    }

    event Staked(
        address indexed staker,
        uint256 amount,
        uint256 lockInPeriod,
        uint256 rewardRate
    );
    event Unstaked(address indexed staker, uint256 amount);
    event RewardClaimed(address indexed staker, uint256 amount);
}
