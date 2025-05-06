// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenReceiver {
    function tokensReceived(address from, uint256 amount) external;
}

contract MyERC20WithCallback {
    string public name = "CallbackToken";
    string public symbol = "CBT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = totalSupply;
    }

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Allowance too low");
        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    function transferWithCallback(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);

        // 如果是合约地址，尝试调用 tokensReceived
        if (isContract(to)) {
            try ITokenReceiver(to).tokensReceived(msg.sender, amount) {
                // success
            } catch {
                revert("Callback failed");
            }
        }

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}
