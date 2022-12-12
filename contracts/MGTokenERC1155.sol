// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract MGTokenERC1155 is ERC1155, Ownable, ERC1155Supply {
  constructor() ERC1155("") {}

  modifier canBatchMint(uint256[] calldata ids) {
    for (uint i; i < ids.length; i++) {
      _canMint(ids[i]);
    }
    _;
  }

  modifier canMint(uint256 id) {
    _canMint(id);
    _;
  }

  function _canMint(uint256 id) internal view {
    require(_maxSupplies[id] > 0, "Can not be minted. Limit is exceeded");
  }

  function preMint(uint256[] calldata ids, uint256[] calldata maxSupplies) external onlyOwner {
    require(maxSupplies.length == ids.length, "maxSupplies and ids length mismatch");

    for (uint i; i < ids.length; i++) {
      require(_maxSupplies[ids[i]] == 0, "Supply already set!");
      _maxSupplies[ids[i]] = maxSupplies[i];
    }
  }

  function mint(
    address account,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) external canMint(id) {
    _mint(account, id, amount, data);
  }

  mapping(uint256 => uint256) private _maxSupplies;

  function mintBatch(
    address to,
    uint256[] calldata ids,
    uint256[] memory amounts,
    bytes memory data
  ) external canBatchMint(ids) {
    _mintBatch(to, ids, amounts, data);
  }

  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal override(ERC1155, ERC1155Supply) {
    super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
  }
}
