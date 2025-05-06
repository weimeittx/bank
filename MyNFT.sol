// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    // NFT合约基本信息
    string public baseURI;
    
    // 最大铸造量
    uint256 public maxSupply = 10000;
    
    // 铸造价格
    uint256 public mintPrice = 1 wei;
    
    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {
        baseURI = "";
    }
    
    // 设置基础URI
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
    
    // 铸造NFT的函数
    function mint(address recipient, string memory tokenURI) public payable returns (uint256) {
        require(_tokenIds.current() < maxSupply, "Maximum casting volume reached");
        require(msg.value >= mintPrice, "Insufficient casting costs");
        
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);
        
        return newItemId;
    }
    
    // 批量铸造NFT
    function batchMint(address recipient, string[] memory tokenURIs) public payable returns (uint256[] memory) {
        require(_tokenIds.current() + tokenURIs.length <= maxSupply, "Exceeding the maximum casting amount");
        require(msg.value >= mintPrice * tokenURIs.length, "Insufficient casting costs");
        
        uint256[] memory newItemIds = new uint256[](tokenURIs.length);
        
        for (uint i = 0; i < tokenURIs.length; i++) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            
            _mint(recipient, newItemId);
            _setTokenURI(newItemId, tokenURIs[i]);
            
            newItemIds[i] = newItemId;
        }
        
        return newItemIds;
    }
    
    // 设置铸造价格
    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }
    
    // 设置最大供应量
    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        maxSupply = _maxSupply;
    }
    
    // 提取合约中的ETH
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
    
    // 获取当前已铸造数量
    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }
} 