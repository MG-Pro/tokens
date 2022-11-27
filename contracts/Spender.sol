// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "hardhat/console.sol";
contract Spender {

    function spend(address tokenContract, address to, uint256 amount) external returns(bool) {
        (bool success, bytes memory result) = tokenContract.call(
            abi.encodeWithSignature("allowance(address,address)", msg.sender, address(this))
        );
        require(success);
        require(uint256(bytes32(result)) >= amount, "Not allowed amount to spend");

        (bool trSuccess,) = tokenContract.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, to, amount)
        );

        require(trSuccess);

        return true;
    }

    function burn(address tokenContract, uint256 amount) external returns(bool) {
        (bool success, bytes memory result) = tokenContract.call(
            abi.encodeWithSignature("allowance(address,address)", msg.sender, address(this))
        );
        require(success);
        require(uint256(bytes32(result)) >= amount, "Not allowed amount to spend");

        (bool trSuccess,) = tokenContract.call(
            abi.encodeWithSignature("burnFrom(address,uint256)", msg.sender, amount)
        );

        require(trSuccess);

        return true;
    }

    function spendNFT(address tokenContract, address to, uint256 tokenId) external returns(bool) {
        (bool success, bytes memory result) = tokenContract.call(
            abi.encodeWithSignature("getApproved(uint256)", tokenId)
        );
        require(success);
        require(address(uint160(uint256(bytes32(result)))) == address(this), "Not Approved for spender");

        (bool trSuccess,) = tokenContract.call(
            abi.encodeWithSignature("safeTransferFrom(address,address,uint256)", msg.sender, to, tokenId)
        );

        require(trSuccess);

        return true;
    }

    function burnNFT(address tokenContract, uint256 amount) external returns(bool) {
        (bool success, bytes memory result) = tokenContract.call(
            abi.encodeWithSignature("allowance(address,address)", msg.sender, address(this))
        );
        require(success);
        require(uint256(bytes32(result)) >= amount, "Not allowed amount to spend");

        (bool trSuccess,) = tokenContract.call(
            abi.encodeWithSignature("burnFrom(address,uint256)", msg.sender, amount)
        );

        require(trSuccess);

        return true;
    }
}
