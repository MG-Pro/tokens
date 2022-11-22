// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// import "hardhat/console.sol";

contract MGTokenERC20 is ERC20 {

    constructor(uint256 _totalSupply) ERC20("MGToken", "MG") {
        _mint(msg.sender, _totalSupply);
    }

}
