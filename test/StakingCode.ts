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
    

        const _StakingContract = await ethers.getContractFactory("CodeStake");
        StakingContract = await _StakingContract.connect(owner).deploy(owner.address, await tokenContract.getAddress());
    });

    it("staking", async function() {
        await tokenContract.connect(owner).mint(staker.address, 10000);
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