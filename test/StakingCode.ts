import { ethers } from "hardhat";
import hre from "hardhat";
import { expect } from "chai";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";


describe("StakingCode", function() {
    let owner: HardhatEthersSigner, staker: HardhatEthersSigner;
    let tokenContract: any;
    let StakingContract: any;


    before(async () => {
        const [_owner, _staker] = await hre.ethers.getSigners();
        owner = _owner;
        staker = _staker;

        const CodeTokenContract = await ethers.getContractFactory("Code")
        tokenContract = await CodeTokenContract.connect(owner).deploy();
        await tokenContract.connect(owner).mint(owner.address, 100000);
        await tokenContract.connect(owner).transfer(staker.address, 10000);
        

        const _StakingContract = await ethers.getContractFactory("CodeStake");
        StakingContract = await _StakingContract.connect(owner).deploy(owner.address, await tokenContract.getAddress());
    });

    it("deposit reward", async function() {
        await tokenContract.connect(owner).approve(await StakingContract.getAddress(), 10000);
        await expect(StakingContract.depositReward(10000))
            .to.emit(StakingContract, "RewardDeposited")
            .withArgs(10000);
    });

    it("withdraw reward", async function() {
        await expect(StakingContract.withdrawReward(1000))
            .to.emit(StakingContract, "RewardWithdrawn")
            .withArgs(1000);
    });

    it("staking", async function() {
        await tokenContract.connect(staker).approve(await StakingContract.getAddress(), 10000);

        await expect(StakingContract.connect(staker).stake(1000, 7 * 24 * 3600))
            .to.emit(StakingContract, "Staked")
            .withArgs(staker.address, 1000, 7 * 24 * 3600, 3);
        
    });
    
    it("claim reward", async function() {
        const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

        await delay(3000);
        await expect(StakingContract.connect(staker).cliamReward(0))
            .to.emit(StakingContract, "RewardClaimed")
            .withArgs(staker.address, 90);
    });

    it("unstaking", async function() {
        await expect(StakingContract.connect(staker).unstake(0))
            .to.emit(StakingContract, "Unstaked")
            .withArgs(staker.address, 900);
    });

})