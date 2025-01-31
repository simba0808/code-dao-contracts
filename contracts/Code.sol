// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Code is ERC20 {
    constructor() ERC20("Code", "CODE") {}

    function decimals() public view virtual override returns (uint8) {
        return 13;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return 10101010101010000000000000;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
