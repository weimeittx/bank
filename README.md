# MyNFT 合约项目

这是一个基于OpenZeppelin ERC721标准的NFT智能合约项目。

## 功能特点

- 基于ERC721标准，完全兼容OpenSea等NFT交易平台
- 支持单个和批量铸造NFT
- 可设置铸造价格和最大供应量
- 拥有者可提取合约中的ETH

## 技术栈

- Solidity ^0.8.0
- OpenZeppelin Contracts v5.0.0
- Hardhat 开发环境

## 安装依赖

```bash
npm install
```

## 编译合约

```bash
npx hardhat compile
```

## 部署合约

```bash
npx hardhat run scripts/deploy.js --network <网络名称>
```

## 合约接口

### 铸造NFT

```solidity
function mint(address recipient, string memory tokenURI) public payable returns (uint256)
```

### 批量铸造NFT

```solidity
function batchMint(address recipient, string[] memory tokenURIs) public payable returns (uint256[] memory)
```

### 设置基础URI

```solidity
function setBaseURI(string memory _newBaseURI) public onlyOwner
```

### 设置铸造价格

```solidity
function setMintPrice(uint256 _mintPrice) public onlyOwner
```

### 设置最大供应量

```solidity
function setMaxSupply(uint256 _maxSupply) public onlyOwner
```

### 提取合约中的ETH

```solidity
function withdraw() public onlyOwner
```

### 获取当前已铸造数量

```solidity
function totalSupply() public view returns (uint256)
```

## 许可证

MIT 