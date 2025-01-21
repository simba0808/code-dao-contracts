// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract TreasuryDonor is ERC721URIStorage {
    address public owner;
    address public treasuryAddress;
    uint256 public donationMinAmount;
    uint256 public nftCnt = 0;

    enum NFTLevel {
        Bronze,
        Silver,
        Gold
    }

    struct NFTMetadata {
        uint256 tokenId;
        NFTLevel level;
        string uri;
    }

    mapping(address => uint256) public donations;
    mapping(address => NFTMetadata) public nftMetadatas;
    mapping(NFTLevel => string) public nftLevelToUri;

    event Donated(address indexed donor, uint256 amount);
    event NFTRewarded(address indexed donor, NFTLevel newLevel);
    event NFTUpgraded(address indexed donor, NFTLevel newLevel);
    event TreasuryUpdated(address indexed treasury);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(
        address _treasuryAddress,
        uint256 _donationMinAmount
    ) ERC721("CODE Donor", "CD") {
        owner = msg.sender;
        treasuryAddress = _treasuryAddress;
        donationMinAmount = _donationMinAmount;

        nftLevelToUri[
            NFTLevel.Bronze
        ] = "https://ipfs.io/ipfs/bafkreifrggkzkzfpdkz56vibku2rrx2ssj5qydg3tuk46vpxnyb2qjys6i";
        nftLevelToUri[
            NFTLevel.Silver
        ] = "https://ipfs.io/ipfs/bafkreidl7z2f5bqta7unt7h2ozlxsg7ql23wvoszvbwxg6a4osklfzch3y";
        nftLevelToUri[
            NFTLevel.Gold
        ] = "https://ipfs.io/ipfs/bafkreib3og7wotiqbydwbma5av6xq4qsglsgz2nvopcukg2wfb7v6nin2q";
    }

    function donate() public payable {
        require(msg.value >= donationMinAmount, "Donation amount too small");
        donations[msg.sender] += msg.value;
        payable(treasuryAddress).transfer(msg.value);

        emit Donated(msg.sender, msg.value);

        rewardNFT(msg.sender);
    }

    function setTreasuryAddress(address _treasuryAddress) public onlyOwner {
        require(
            treasuryAddress != _treasuryAddress &&
                _treasuryAddress != address(0)
        );
        treasuryAddress = _treasuryAddress;

        emit TreasuryUpdated(_treasuryAddress);
    }

    function rewardNFT(address donor) internal {
        NFTLevel lvl = _determineNFTLvl(donor);

        if (nftMetadatas[donor].tokenId == 0) {
            _mintNFT(donor, lvl);
        } else if (nftMetadatas[donor].level != lvl) {
            upgradeNFTLevel(donor, lvl);
        }
    }

    function upgradeNFTLevel(address _nftOwner, NFTLevel _lvl) internal {
        nftMetadatas[_nftOwner].level = _lvl;

        emit NFTUpgraded(_nftOwner, _lvl);
    }

    function _determineNFTLvl(address donor) internal view returns (NFTLevel) {
        uint256 donationAmount = donations[donor];

        if (donationAmount >= 0.1 ether) {
            return NFTLevel.Gold;
        } else if (donationAmount >= 0.05 ether) {
            return NFTLevel.Silver;
        } else {
            return NFTLevel.Bronze;
        }
    }

    function _mintNFT(address _recipient, NFTLevel _lvl) internal {
        nftCnt++;
        _mint(_recipient, nftCnt);
        _setTokenURI(nftCnt, nftLevelToUri[_lvl]);

        nftMetadatas[_recipient] = NFTMetadata({
            tokenId: nftCnt,
            level: _lvl,
            uri: nftLevelToUri[_lvl]
        });

        emit NFTRewarded(_recipient, _lvl);
    }
}
