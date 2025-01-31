// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 *  ____  _______  _______           _
 * |  _ \| ____\ \/ /_   _|__   ___ | |___
 * | | | |  _|  \  /  | |/ _ \ / _ \| / __|
 * | |_| | |___ /  \  | | (_) | (_) | \__ \
 * |____/|_____/_/\_\ |_|\___/ \___/|_|___/
 *
 * This smart contract was created effortlessly using the DEXTools Token Creator.
 *
 * 🌐 Website: https://www.dextools.io/
 * 🐦 Twitter: https://twitter.com/DEXToolsApp
 * 💬 Telegram: https://t.me/DEXToolsCommunity
 *
 * 🚀 Unleash the power of decentralized finances and tokenization with DEXTools Token Creator. Customize your token seamlessly. Manage your created tokens conveniently from your user panel - start creating your dream token today!
 */
interface IAntiBot {
    function setTokenOwner(address owner) external;

    function onPreTransferCheck(address from, address to) external;

    function addToBlacklist(
        address owner,
        address[] calldata addresses
    ) external;

    function removeFromBlacklist(address owner, address account) external;

    function getBlacklistStatus(
        address token
    ) external view returns (uint256, uint256, uint256, uint256);

    function getBlacklist(
        address token
    ) external view returns (address[] memory);

    function isBlacklisted(
        address token,
        address account
    ) external view returns (bool);
}
