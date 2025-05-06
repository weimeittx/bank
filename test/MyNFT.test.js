const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyNFT", function () {
  let myNFT;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    // 获取测试账户
    [owner, addr1, addr2] = await ethers.getSigners();

    // 部署合约
    const MyNFT = await ethers.getContractFactory("MyNFT");
    myNFT = await MyNFT.deploy();
    await myNFT.waitForDeployment();
  });

  describe("部署", function () {
    it("应该设置正确的所有者", async function () {
      expect(await myNFT.owner()).to.equal(owner.address);
    });

    it("应该设置正确的名称和符号", async function () {
      expect(await myNFT.name()).to.equal("MyNFT");
      expect(await myNFT.symbol()).to.equal("MNFT");
    });

    it("初始供应量应该为0", async function () {
      expect(await myNFT.totalSupply()).to.equal(0);
    });
  });

  describe("铸造", function () {
    it("可以铸造NFT", async function () {
      const mintPrice = await myNFT.mintPrice();
      await myNFT.mint(addr1.address, "ipfs://QmTest", { value: mintPrice });
      
      expect(await myNFT.totalSupply()).to.equal(1);
      expect(await myNFT.balanceOf(addr1.address)).to.equal(1);
      expect(await myNFT.ownerOf(1)).to.equal(addr1.address);
      expect(await myNFT.tokenURI(1)).to.equal("ipfs://QmTest");
    });

    it("不支付足够金额无法铸造", async function () {
      const mintPrice = await myNFT.mintPrice();
      await expect(
        myNFT.mint(addr1.address, "ipfs://QmTest", { value: mintPrice.sub(1) })
      ).to.be.revertedWith("铸造费用不足");
    });

    it("可以批量铸造NFT", async function () {
      const mintPrice = await myNFT.mintPrice();
      const tokenURIs = ["ipfs://QmTest1", "ipfs://QmTest2", "ipfs://QmTest3"];
      
      await myNFT.batchMint(addr1.address, tokenURIs, { 
        value: mintPrice.mul(tokenURIs.length) 
      });
      
      expect(await myNFT.totalSupply()).to.equal(3);
      expect(await myNFT.balanceOf(addr1.address)).to.equal(3);
      
      for (let i = 0; i < tokenURIs.length; i++) {
        expect(await myNFT.ownerOf(i + 1)).to.equal(addr1.address);
        expect(await myNFT.tokenURI(i + 1)).to.equal(tokenURIs[i]);
      }
    });
  });

  describe("所有者功能", function () {
    it("可以设置铸造价格", async function () {
      const newPrice = ethers.utils.parseEther("0.1");
      await myNFT.setMintPrice(newPrice);
      expect(await myNFT.mintPrice()).to.equal(newPrice);
    });

    it("可以设置最大供应量", async function () {
      const newMaxSupply = 20000;
      await myNFT.setMaxSupply(newMaxSupply);
      expect(await myNFT.maxSupply()).to.equal(newMaxSupply);
    });

    it("可以设置基础URI", async function () {
      const newBaseURI = "https://example.com/";
      await myNFT.setBaseURI(newBaseURI);
      expect(await myNFT.baseURI()).to.equal(newBaseURI);
    });

    it("可以提取合约中的ETH", async function () {
      // 先铸造一个NFT来添加ETH到合约
      const mintPrice = await myNFT.mintPrice();
      await myNFT.mint(addr1.address, "ipfs://QmTest", { value: mintPrice });
      
      const initialBalance = await ethers.provider.getBalance(owner.address);
      
      // 提取合约中的ETH
      await myNFT.withdraw();
      
      // 检查所有者余额是否增加
      const finalBalance = await ethers.provider.getBalance(owner.address);
      expect(finalBalance.gt(initialBalance)).to.be.true;
    });

    it("非所有者不能调用所有者功能", async function () {
      // 使用非所有者账户
      const connectedNFT = myNFT.connect(addr1);
      
      await expect(connectedNFT.setMintPrice(ethers.utils.parseEther("0.1")))
        .to.be.reverted;
        
      await expect(connectedNFT.setMaxSupply(20000))
        .to.be.reverted;
        
      await expect(connectedNFT.setBaseURI("https://example.com/"))
        .to.be.reverted;
        
      await expect(connectedNFT.withdraw())
        .to.be.reverted;
    });
  });
}); 