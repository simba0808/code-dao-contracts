import { ethers } from "hardhat";
import hre from "hardhat";
import { expect } from "chai";

describe("TreasuryDonor", function () {
    let treasuryDonorContract: any;
    let donor_account: any;
    let donor_account_2: any;
    let owner_account: any;
    let treasury_account: any;

    enum NFTLevel {
        Bronze,
        Silver,
        Gold
    }


    before(async () => {
        const [_owner, _treasury_wallet, _donor_wallet, _donor_wallet_2] = await hre.ethers.getSigners();
        owner_account = _owner;
        treasury_account = _treasury_wallet;
        donor_account = _donor_wallet;
        donor_account_2 = _donor_wallet_2;

        const DonateContract = await ethers.getContractFactory("TreasuryDonor", owner_account);
        treasuryDonorContract = await DonateContract.deploy(owner_account.address, treasury_account.address, 100000);
    });

    it("Donate funds", async function() {
        const donateAmount = ethers.parseEther("0.35");
    
        await expect(treasuryDonorContract.connect(donor_account).donate({ value: donateAmount }))
            .to.emit(treasuryDonorContract, "DonationReceived")
            .withArgs(donor_account.address, ethers.parseEther("0.35"));
    });

    it("NFT Rewarded - mint new nft", async function() {
        const donateAmount = ethers.parseEther("0.35");

        await expect(treasuryDonorContract.connect(donor_account_2).donate({ value: donateAmount }))
        .to.emit(treasuryDonorContract, "NFTMinted")
        .withArgs(donor_account_2.address, NFTLevel.Silver);
    });

    it("NFT Rewarded - upgraded the level of nft", async function() {
        const donateAmount = ethers.parseEther("0.35");

        await expect(treasuryDonorContract.connect(donor_account).donate({ value: donateAmount }))
        .to.emit(treasuryDonorContract, "NFTUpgraded")
        .withArgs(donor_account.address, NFTLevel.Gold);
    });

    it("Treasury Update with non-owner", async function() {
        const [new_treasury] = await hre.ethers.getSigners();

        await expect(treasuryDonorContract.connect(donor_account).updateTreasuryWallet(new_treasury.address))
            .to.be.revertedWithCustomError(treasuryDonorContract, "OwnableUnauthorizedAccount");
    });

    it("Treasury Update", async function() {
        const [new_treasury] = await hre.ethers.getSigners();

        await expect(treasuryDonorContract.connect(owner_account).updateTreasuryWallet(new_treasury.address))
            .to.emit(treasuryDonorContract, "TreasuryWalletUpdated")
            .withArgs(new_treasury.address);
    });

    it("Transfer Ownership", async function() {
        const [new_owner] = await hre.ethers.getSigners();
        
        await expect(treasuryDonorContract.connect(owner_account).transferOwnership(new_owner.address))
            .to.emit(treasuryDonorContract, "OwnershipTransferred")
            .withArgs(owner_account.address, new_owner.address);
    })

});