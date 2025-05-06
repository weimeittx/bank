// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenReceiver {
    function tokensReceived(address from, uint256 amount) external;
}

interface IMyERC20WithCallback {
    function transferWithCallback(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract TokenBankV2 is ITokenReceiver {
    IMyERC20WithCallback public token;

    mapping(address => uint256) public balances;

    constructor(address _token) {
        token = IMyERC20WithCallback(_token);
    }

    /// 手动存入（传统方式）
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be positive");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        balances[msg.sender] += amount;
    }

    /// 从合约中取出并调用 transferWithCallback（自动调用接收方 tokensReceived）
    function withdrawWithCallback(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;

        bool success = token.transferWithCallback(to, amount);
        require(success, "Transfer with callback failed");
    }

    /// token.transferWithCallback() 会自动回调此函数
    function tokensReceived(address from, uint256 amount) external override {
        require(msg.sender == address(token), "Only token contract can call");
        balances[from] += amount;
    }
}
