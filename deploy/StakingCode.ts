import hre from "hardhat";

async function main() {
    try {

        const tokenContractFactory = await hre.ethers.getContractFactory("Code");
        const tokenContract = await tokenContractFactory.deploy();
        const tokenAddress = await tokenContract.getAddress();
        console.log("ERC20 Address: ", tokenAddress);

        // Get the ContractFactory of your SimpleContract
        const StakingContract = await hre.ethers.getContractFactory("CodeStake");

        // Deploy the contract
        const contract = await StakingContract.deploy("0xf907e8cEC2A0575B4e895eB7720300F88694022e", tokenAddress);

        // Wait for the deployment transaction to be mined
        const address = await contract.getAddress();

        console.log(`Staking Contract deployed to: ${address}`);
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
}

main();