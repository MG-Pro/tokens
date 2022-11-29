import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe("MGTokenERC20", () => {
  const totalSupply = 1_000_000;

  async function deploy() {
    const [deployer1, deployer2, user1, user2] = await ethers.getSigners();
    const MGTokenERC20 = await ethers.getContractFactory(
      "MGTokenERC20",
      deployer1
    );
    const Spender = await ethers.getContractFactory("Spender", deployer2);

    const contractToken = await MGTokenERC20.deploy(totalSupply);
    const contractSpender = await Spender.deploy();
    await contractToken.deployed();
    await contractSpender.deployed();

    return {
      contractToken,
      contractSpender,
      user1,
      user2,
      deployer1,
      deployer2,
    };
  }

  it("Should show supply", async () => {
    const { contractToken } = await loadFixture(deploy);
    expect(await contractToken.totalSupply()).to.equal(totalSupply);
  });

  it("Should full supply on deployer", async () => {
    const { contractToken, deployer1 } = await loadFixture(deploy);
    expect(await contractToken.balanceOf(deployer1.address)).to.equal(
      totalSupply
    );
  });

  it("Should make transfer", async () => {
    const { contractToken, deployer1, user1 } = await loadFixture(deploy);
    const amount = 500_000;

    await contractToken.connect(deployer1).transfer(user1.address, amount);
    expect(await contractToken.balanceOf(user1.address)).to.equal(amount);
  });

  it("Should make transfer via Spender", async () => {
    const { contractToken, contractSpender, deployer1, user1, user2 } =
      await loadFixture(deploy);
    const amount1 = 500_000;
    const amount2 = 250_000;

    await contractToken.connect(deployer1).transfer(user1.address, amount1);
    await contractToken
      .connect(user1)
      .approve(contractSpender.address, amount2);

    await contractSpender
      .connect(user1)
      .spend(contractToken.address, user2.address, amount2);
    expect(await contractToken.balanceOf(user2.address)).to.equal(amount2);
  });

  it("Should burn tokens via Spender", async () => {
    const { contractToken, contractSpender, deployer1, user1, user2 } =
      await loadFixture(deploy);
    const amount1 = 500_000;
    const amount2 = 250_000;
    const burnAmount = 100_000;

    await contractToken.connect(deployer1).transfer(user1.address, amount1);
    await contractToken
      .connect(user1)
      .approve(contractSpender.address, amount2);

    await contractSpender
      .connect(user1)
      .spend(contractToken.address, user2.address, amount2);

    await contractToken
      .connect(user2)
      .approve(contractSpender.address, amount2);
    await contractSpender
      .connect(user2)
      .burn(contractToken.address, burnAmount);

    expect(await contractToken.balanceOf(user2.address)).to.equal(
      amount2 - burnAmount
    );
  });
});

describe("MGTokenERC721", () => {
  async function deploy() {
    const [deployer1, deployer2, user1, user2] = await ethers.getSigners();
    const MGTokenERC721 = await ethers.getContractFactory(
      "MGTokenERC721",
      deployer1
    );
    const Spender = await ethers.getContractFactory("Spender", deployer2);

    const contractToken = await MGTokenERC721.deploy();
    const contractSpender = await Spender.deploy();
    await contractToken.deployed();
    await contractSpender.deployed();

    return {
      contractToken,
      contractSpender,
      user1,
      user2,
      deployer1,
      deployer2,
    };
  }

  it("Should mint NFTs", async () => {
    const { contractToken, deployer1 } = await loadFixture(deploy);

    await contractToken.connect(deployer1).safeMint(deployer1.address);
    await contractToken.connect(deployer1).safeMint(deployer1.address);

    expect(
      await contractToken.connect(deployer1).balanceOf(deployer1.address)
    ).to.equal(2);
  });

  it("Should transfer NFT", async () => {
    const { contractToken, deployer1, user1 } = await loadFixture(deploy);

    await contractToken.connect(deployer1).safeMint(deployer1.address);
    await contractToken
      .connect(deployer1)
      .transferFrom(deployer1.address, user1.address, 0);

    expect(
      await contractToken.connect(deployer1).balanceOf(deployer1.address)
    ).to.equal(0);
    expect(
      await contractToken.connect(deployer1).balanceOf(user1.address)
    ).to.equal(1);
  });

  it("Should transfer NFT via spender", async () => {
    const { contractToken, contractSpender, deployer1, user1 } =
      await loadFixture(deploy);

    await contractToken.connect(deployer1).safeMint(deployer1.address);
    const tokenId = await contractToken
      .connect(deployer1)
      .tokenOfOwnerByIndex(deployer1.address, 0);
    await contractToken
      .connect(deployer1)
      .approve(contractSpender.address, tokenId);

    await contractSpender
      .connect(deployer1)
      .spendNFT(contractToken.address, user1.address, tokenId);

    expect(
      await contractToken.connect(deployer1).balanceOf(deployer1.address)
    ).to.equal(0);
    expect(
      await contractToken.connect(deployer1).balanceOf(user1.address)
    ).to.equal(1);
  });

  it("Should burn NFT via spender", async () => {
    const { contractToken, contractSpender, deployer1 } = await loadFixture(
      deploy
    );

    await contractToken.connect(deployer1).safeMint(deployer1.address);
    const tokenId = await contractToken
      .connect(deployer1)
      .tokenOfOwnerByIndex(deployer1.address, 0);
    await contractToken
      .connect(deployer1)
      .approve(contractSpender.address, tokenId);

    expect(
      await contractToken.connect(deployer1).balanceOf(deployer1.address)
    ).to.equal(1);
    await contractSpender
      .connect(deployer1)
      .burnNFT(contractToken.address, tokenId);

    expect(
      await contractToken.connect(deployer1).balanceOf(deployer1.address)
    ).to.equal(0);
  });

  it("Should set right URL", async () => {
    const { contractToken, deployer1 } = await loadFixture(deploy);
    const baseURI = "192.168.0.1/";

    await contractToken.connect(deployer1).safeMint(deployer1.address);
    const tokenId = await contractToken
      .connect(deployer1)
      .tokenOfOwnerByIndex(deployer1.address, 0);

    expect(await contractToken.tokenURI(tokenId)).to.equal(baseURI + tokenId);
  });
});
