// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IWETH9 {
    function deposit() external payable;
    function withdraw(uint256 _amount) external;
    event Deposit(address indexed from, uint amount);
    event Withdraw(address indexed to , uint amount);
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    
    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}

contract Weth is IWETH9, IERC20 {
    string public name = "Wrapped Ether";
    string public token = "WETH";
    uint8 public decimals = 18;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    function totalSupply() public view returns(uint) {
        return address(this).balance;
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function deposit() external payable {
        balanceOf[msg.sender] += msg.value;
        emit Transfer(address(0x0), msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        require(balanceOf[msg.sender] >= _amount);
        balanceOf[msg.sender] -= _amount;
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success);
        emit Transfer(msg.sender, address(0x0), _amount);
        emit Withdraw(msg.sender, _amount);
    }

    receive() external payable {
        balanceOf[msg.sender] += msg.value;
        emit Transfer(address(0x0), msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }
}