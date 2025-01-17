import { ethers } from "hardhat";
import hre from "hardhat";
import { expect } from "chai";

describe("Donate", function () {
    let contract: any;
    let donor_wallet: any;
    let owner_wallet: any;
    let treasury_wallet: any;
    
    before(async () => {
        const [_owner, _treasury_wallet, _donor_wallet] = await hre.ethers.getSigners();
        owner_wallet =  _owner;
        donor_wallet = _donor_wallet;
        treasury_wallet = _treasury_wallet

        const DonateContract = await ethers.getContractFactory("Donate", owner_wallet);
        contract = await DonateContract.deploy(treasury_wallet.address, 100000);
    });

    it("Donate funds", async function() {
        const donateAmount = ethers.parseEther("0.0015");
        console.log(donateAmount)
        await expect(contract.connect(donor_wallet).donate({ value: donateAmount }))
            .to.emit(contract, "Donated")
            .withArgs(donor_wallet.address, donateAmount);
    });

    it("Treasury Update with non-owner", async function() {
        const [new_treasury] = await hre.ethers.getSigners();

        await expect(contract.connect(donor_wallet).setTreasuryAddress(new_treasury.address))
            .to.be.revertedWith("Only owner can call this function");
    });

    it("Treasury Update", async function() {
        const [new_treasury] = await hre.ethers.getSigners();

        await expect(contract.connect(owner_wallet).setTreasuryAddress(new_treasury.address))
            .to.emit(contract, "TreasuryUpdated")
            .withArgs(new_treasury.address);
    });
})