import { expect } from "chai";
import { ethers } from "hardhat";
import {loadFixture} from '@nomicfoundation/hardhat-network-helpers'


describe("MGTokenERC20", () => {
  const totalSupply = 1_000_000

  async function deploy() {
    const [deployer1, deployer2, user1, user2] = await ethers.getSigners()
    const MGTokenERC20 = await ethers.getContractFactory('MGTokenERC20', deployer1)
    const Spender = await ethers.getContractFactory('Spender', deployer2)

    const contractToken = await MGTokenERC20.deploy(totalSupply)
    const contractSpender = await Spender.deploy()
    await contractToken.deployed()
    await contractSpender.deployed()

    return {contractToken, contractSpender, user1, user2, deployer1, deployer2}
  }

  it('Should show supply', async () => {
    const {contractToken} = await loadFixture(deploy)
    expect(await contractToken.totalSupply()).to.equal(totalSupply)
  })

  it('Should full supply on deployer', async () => {
    const {contractToken, deployer1} = await loadFixture(deploy)
    expect(await contractToken.balanceOf(deployer1.address)).to.equal(totalSupply)
  })

  it('Should make transfer', async () => {
    const {contractToken, deployer1, user1} = await loadFixture(deploy)
    const amount = 500_000

    await contractToken.connect(deployer1).transfer(user1.address, amount)
    expect(await contractToken.balanceOf(user1.address)).to.equal(amount)
  })

  it('Should make transfer via Spender', async () => {
    const {contractToken, contractSpender, deployer1, user1, user2} = await loadFixture(deploy)
    const amount1 = 500_000
    const amount2 = 250_000

    await contractToken.connect(deployer1).transfer(user1.address, amount1)
    await contractToken.connect(user1).approve(contractSpender.address, amount2)

    await contractSpender.connect(user1).spend(contractToken.address, user2.address, amount2)
    expect(await contractToken.balanceOf(user2.address)).to.equal(amount2)
  })
});
