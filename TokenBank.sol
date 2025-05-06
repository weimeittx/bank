// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TokenBank {
    IERC20 public token;

    // 存储每个地址的 token 存入量
    mapping(address => uint256) public balances;

    constructor(address _token) {
        token = IERC20(_token);
    }

    /// @notice 存入 token 到 TokenBank
    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than 0");

        // 将 token 从用户账户转到合约账户（前提：approve 已执行）
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

        // 更新用户余额
        balances[msg.sender] += amount;
    }

    /// @notice 从 TokenBank 提取之前存入的 token
    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdraw amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // 更新用户余额
        balances[msg.sender] -= amount;

        // 将 token 转回用户
        bool success = token.transfer(msg.sender, amount);
        require(success, "Token transfer failed");
    }
}
