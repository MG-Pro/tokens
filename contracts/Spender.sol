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
}
