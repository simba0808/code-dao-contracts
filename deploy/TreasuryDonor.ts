import hre from "hardhat";
import { ethers } from "hardhat";

async function main() {
    try {
        const donate_amount_min = ethers.parseEther("0.0015");
    
        // Get the ContractFactory of your SimpleContract
        const DonateContract = await hre.ethers.getContractFactory("TreasuryDonor");

        // Deploy the contract
        const contract = await DonateContract.deploy("0xf907e8cEC2A0575B4e895eB7720300F88694022e", donate_amount_min);

        // Wait for the deployment transaction to be mined
        const address = await contract.getAddress();

        console.log(`DonateContract deployed to: ${address}`);
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
}

main();