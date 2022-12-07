// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";

contract Spender is IERC777Recipient {
  bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
  IERC1820Registry internal constant _ERC1820_REGISTRY =
    IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

  constructor() {
    _ERC1820_REGISTRY.setInterfaceImplementer(
      address(this),
      _TOKENS_RECIPIENT_INTERFACE_HASH,
      address(this)
    );
  }

  function spend(address tokenContract, address to, uint256 amount) external returns (bool) {
    (bool success, bytes memory result) = tokenContract.call(
      abi.encodeWithSignature("allowance(address,address)", msg.sender, address(this))
    );
    require(success);
    require(uint256(bytes32(result)) >= amount, "Not allowed amount to spend");

    (bool trSuccess, ) = tokenContract.call(
      abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, to, amount)
    );

    require(trSuccess);

    return true;
  }

  function burn(address tokenContract, uint256 amount) external returns (bool) {
    (bool success, bytes memory result) = tokenContract.call(
      abi.encodeWithSignature("allowance(address,address)", msg.sender, address(this))
    );
    require(success);
    require(uint256(bytes32(result)) >= amount, "Not allowed amount to spend");

    (bool trSuccess, ) = tokenContract.call(
      abi.encodeWithSignature("burnFrom(address,uint256)", msg.sender, amount)
    );

    require(trSuccess);

    return true;
  }

  function spendNFT(address tokenContract, address to, uint256 tokenId) external returns (bool) {
    (bool success, bytes memory result) = tokenContract.call(
      abi.encodeWithSignature("getApproved(uint256)", tokenId)
    );
    require(success);
    require(
      address(uint160(uint256(bytes32(result)))) == address(this),
      "Not Approved for spender"
    );

    (bool trSuccess, ) = tokenContract.call(
      abi.encodeWithSignature("safeTransferFrom(address,address,uint256)", msg.sender, to, tokenId)
    );

    require(trSuccess);

    return true;
  }

  function burnNFT(address tokenContract, uint256 tokenId) external returns (bool) {
    (bool success, bytes memory result) = tokenContract.call(
      abi.encodeWithSignature("getApproved(uint256)", tokenId)
    );
    require(success);
    require(
      address(uint160(uint256(bytes32(result)))) == address(this),
      "Not Approved for spender"
    );

    (bool trSuccess, ) = tokenContract.call(abi.encodeWithSignature("burn(uint256)", tokenId));

    require(trSuccess);

    return true;
  }

  function spendAsOperator(
    address tokenContract,
    address from,
    address to,
    uint256 amount
  ) external returns (bool) {
    (bool success, bytes memory result) = tokenContract.call(
      abi.encodeWithSignature("isOperatorFor(address,address)", address(this), from)
    );
    require(success);
    require(uint256(bytes32(result)) == 1, "Not operator");

    (bool trSuccess, ) = tokenContract.call(
      abi.encodeWithSignature(
        "operatorSend(address,address,uint256,bytes,bytes)",
        from,
        to,
        amount,
        "",
        ""
      )
    );

    require(trSuccess, "operatorSend error");

    return true;
  }

  function sendOwnToken(address tokenContract, address to, uint256 amount) external returns (bool) {
    (bool success, bytes memory result) = tokenContract.call(
      abi.encodeWithSignature("balanceOf(address)", address(this))
    );
    require(success);
    console.log(uint256(bytes32(result)));
    require(uint256(bytes32(result)) <= amount, "Not enough tokens");

    (bool trSuccess, ) = tokenContract.call(
      abi.encodeWithSignature("send(address,uint256,bytes)", to, amount, "")
    );

    require(trSuccess, "send error");

    return true;
  }

  function tokensReceived(
    address operator,
    address from,
    address to,
    uint256 amount,
    bytes calldata userData,
    bytes calldata operatorData
  ) external {}
}
