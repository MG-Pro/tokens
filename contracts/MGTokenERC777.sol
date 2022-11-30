// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Sender.sol";
import "@openzeppelin/contracts/token/ERC777/presets/ERC777PresetFixedSupply.sol";
import "hardhat/console.sol";

contract MGTokenERC777 is IERC777Sender, ERC777PresetFixedSupply {
  event BeforeTokenSend(
    address operator,
    address from,
    address to,
    uint256 amount,
    bytes userData,
    bytes operatorData
  );

  constructor(
    uint256 initialSupply,
    address[] memory defaultOperators
  ) ERC777PresetFixedSupply("MGToken", "MG", defaultOperators, initialSupply, msg.sender) {}

  function tokensToSend(
    address operator,
    address from,
    address to,
    uint256 amount,
    bytes calldata userData,
    bytes calldata operatorData
  ) external override {
    emit BeforeTokenSend(operator, from, to, amount, userData, operatorData);
  }
}
