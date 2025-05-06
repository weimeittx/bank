// 用于部署MyNFT合约的脚本
const hre = require("hardhat");

async function main() {
  console.log("开始部署MyNFT合约...");

  // 获取合约工厂
  const MyNFT = await hre.ethers.getContractFactory("MyNFT");
  
  // 部署合约
  const myNFT = await MyNFT.deploy();
  
  // 等待合约部署完成
  await myNFT.waitForDeployment();
  
  // 获取合约地址
  const myNFTAddress = await myNFT.getAddress();
  
  console.log("MyNFT合约已部署到地址:", myNFTAddress);
}

// 执行部署函数
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 