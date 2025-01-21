// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TreasuryDonor is ERC721URIStorage, ReentrancyGuard {
    address public immutable contractOwner;
    address public treasuryWallet;
    uint256 public immutable minimumDonation;
    uint256 public totalMintedNFTs;

    enum DonationLevel {
        Bronze,
        Silver,
        Gold
    }

    struct DonorData {
        uint256 cumulativeDonations;
        uint256 nftTokenId;
        DonationLevel currentLevel;
    }

    mapping(address => DonorData) public donorDetails;
    mapping(DonationLevel => string) public donationLevelToURI;

    event DonationReceived(address indexed donor, uint256 amount);
    event NFTMinted(address indexed donor, DonationLevel level);
    event NFTUpgraded(address indexed donor, DonationLevel newLevel);
    event TreasuryWalletUpdated(address indexed newTreasuryWallet);

    modifier onlyContractOwner() {
        require(
            msg.sender == contractOwner,
            "Only the contract owner can call this function"
        );
        _;
    }

    constructor(
        address _treasuryWallet,
        uint256 _minimumDonation
    ) ERC721("CODE Donor", "CD") {
        require(
            _treasuryWallet != address(0),
            "Invalid treasury wallet address"
        );
        require(_minimumDonation > 0, "Minimum donation must be positive");

        contractOwner = msg.sender;
        treasuryWallet = _treasuryWallet;
        minimumDonation = _minimumDonation;

        // Initialize default URIs for donation levels
        donationLevelToURI[
            DonationLevel.Bronze
        ] = "https://ipfs.io/ipfs/bafkreifrggkzkzfpdkz56vibku2rrx2ssj5qydg3tuk46vpxnyb2qjys6i";
        donationLevelToURI[
            DonationLevel.Silver
        ] = "https://ipfs.io/ipfs/bafkreidl7z2f5bqta7unt7h2ozlxsg7ql23wvoszvbwxg6a4osklfzch3y";
        donationLevelToURI[
            DonationLevel.Gold
        ] = "https://ipfs.io/ipfs/bafkreib3og7wotiqbydwbma5av6xq4qsglsgz2nvopcukg2wfb7v6nin2q";
    }

    /// @dev Allows donors to send ETH and receive or upgrade NFTs.
    function donate() external payable nonReentrant {
        require(msg.value >= minimumDonation, "Donation amount is too small");

        // Transfer funds to the treasury wallet
        (bool success, ) = treasuryWallet.call{value: msg.value}("");
        require(success, "Failed to transfer funds to the treasury wallet");

        // Update donor data
        DonorData storage donorData = donorDetails[msg.sender];
        donorData.cumulativeDonations += msg.value;

        emit DonationReceived(msg.sender, msg.value);

        // Handle NFT minting or upgrading
        _handleNFTReward(msg.sender, donorData);
    }

    /// @dev Updates the treasury wallet address. Only callable by the contract owner.
    function updateTreasuryWallet(
        address _newTreasuryWallet
    ) external onlyContractOwner {
        require(
            _newTreasuryWallet != address(0),
            "Invalid treasury wallet address"
        );
        require(
            treasuryWallet != _newTreasuryWallet,
            "New address is the same as the current address"
        );

        treasuryWallet = _newTreasuryWallet;
        emit TreasuryWalletUpdated(_newTreasuryWallet);
    }

    /// @dev Updates the URI for a specific donation level. Only callable by the contract owner.
    function setDonationLevelURI(
        DonationLevel _level,
        string calldata _uri
    ) external onlyContractOwner {
        require(bytes(_uri).length > 0, "URI cannot be empty");
        donationLevelToURI[_level] = _uri;
    }

    /// @dev Determines the NFT level based on the total donations of the donor.
    function _getDonationLevel(
        uint256 totalDonations
    ) internal pure returns (DonationLevel) {
        if (totalDonations >= 0.5 ether) {
            return DonationLevel.Gold;
        } else if (totalDonations >= 0.2 ether) {
            return DonationLevel.Silver;
        } else {
            return DonationLevel.Bronze;
        }
    }

    /// @dev Handles the NFT reward logic (minting or upgrading) for a donor.
    function _handleNFTReward(
        address donor,
        DonorData storage donorData
    ) internal {
        DonationLevel newLevel = _getDonationLevel(
            donorData.cumulativeDonations
        );

        if (donorData.nftTokenId == 0) {
            // Mint a new NFT if the donor doesn't have one
            _mintNFT(donor, newLevel, donorData);
        } else if (donorData.currentLevel != newLevel) {
            // Upgrade the existing NFT if the level has changed
            _upgradeNFT(donor, newLevel, donorData);
        }
    }

    /// @dev Mints a new NFT for the donor.
    function _mintNFT(
        address donor,
        DonationLevel level,
        DonorData storage donorData
    ) internal {
        totalMintedNFTs++;
        uint256 newTokenId = totalMintedNFTs;

        _mint(donor, newTokenId);
        _setTokenURI(newTokenId, donationLevelToURI[level]);

        donorData.nftTokenId = newTokenId;
        donorData.currentLevel = level;

        emit NFTMinted(donor, level);
    }

    /// @dev Upgrades the level and URI of an existing NFT.
    function _upgradeNFT(
        address donor,
        DonationLevel newLevel,
        DonorData storage donorData
    ) internal {
        donorData.currentLevel = newLevel;
        _setTokenURI(donorData.nftTokenId, donationLevelToURI[newLevel]);

        emit NFTUpgraded(donor, newLevel);
    }

    /// @dev Fallback function to prevent accidental Ether loss.
    receive() external payable {
        revert("Use the donate function to send ETH");
    }

    fallback() external payable {
        revert("Invalid function call");
    }
}
