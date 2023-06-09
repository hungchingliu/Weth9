// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/Weth.sol";
import "forge-std/Test.sol";

contract WethTest is Test {
    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    Weth public weth;
    address user1 = address(1);
    address user2 = address(2);

    function setUp() public {
        weth = new Weth();
        vm.label(user1, "BOB");
        vm.label(user2, "Alice");

        uint256 initialBalance = 1 ether;
        vm.deal(user1, initialBalance);
        vm.deal(user2, initialBalance);
    }

    function test_DepositMintTokenToSender() public {
        // 1. pretend we are user1
        // 2. call weth.deposit(1 ether);
        // 3. assert weth.balanceOf(user1) == 1 ether
        uint256 depositAmount = 1 ether;

        vm.prank(user1);
        weth.deposit{value: depositAmount}();
        assertEq(weth.balanceOf(user1), depositAmount);
    }

    function test_DepositTransferEthToContract() public {
        // 1. pretend we are user 1
        // 2. call weth.deposit(1 ether);
        // 3. assert WETH contract receive ethers
        uint256 depositAmount = 1 ether;

        vm.prank(user1);
        weth.deposit{value: depositAmount}();
        assertEq(weth.totalSupply(), depositAmount);
        assertEq(address(weth).balance, depositAmount);
    }

    function test_DespositEmitDepositEvent() public {
        // 1. declare Deposit event we expect to emit
        // 2. pretend we are user1
        // 3. call weth.deposit(1 ether);
        uint256 depositAmount = 1 ether;

        vm.expectEmit();
        emit Deposit(user1, depositAmount);

        vm.prank(user1);
        weth.deposit{value: depositAmount}();
    }

    function test_WithdrawBurnTokens() public {
        // 1. deposit 1 ether to user1 WETH account
        // 2. assert weth.totalSupply = 1 ether
        // 3. call weth.withdraw(_amount);
        // 4. assert weth.totalSupply = 0 ether
        uint256 depositAmount = 1 ether;

        vm.prank(user1);
        weth.deposit{value: depositAmount}();

        assertEq(weth.totalSupply(), depositAmount);
        vm.prank(user1);
        weth.withdraw(depositAmount);
        assertEq(weth.totalSupply(), 0 ether);
    }

    function test_WithdrawSendEthToSender() public {
        // 1. deposit 1 ether to user1 WETH account
        // 2. assert user1.balance == 0
        // 3. call weth.withdraw(1 ether)
        // 4. assert user1.balance = 1 ether
        uint256 depositAmount = 1 ether;

        vm.prank(user1);
        weth.deposit{value: depositAmount}();

        assertEq(user1.balance, 0);
        vm.prank(user1);
        weth.withdraw(depositAmount);
        assertEq(user1.balance, depositAmount);
    }

    function test_WithdrawEmitWithdrawEvent() public {
        // 1. deposit 1 ether to user1 WETH account
        // 2. declare Withdraw event we expect to emit
        // 3. call weth.withdraw(1 ether);
        uint256 depositAmount = 1 ether;

        vm.prank(user1);
        weth.deposit{value: depositAmount}();

        vm.expectEmit();
        emit Withdraw(user1, depositAmount);
        vm.prank(user1);
        weth.withdraw(depositAmount);
    }

    function test_TransferSendTokenToReceiver() public {
        // 1. deposit 1 ether to user1 WETH account
        // 2. call weth.transfer(user2, 1 ether);
        // 3. assert weth.balanceOf(user1) == 0
        // 4. assert weth.balanceOf(user2) == 1 ether;
        uint256 depositAmount = 1 ether;
        uint256 transferAmount = 1 ether;

        vm.prank(user1);
        weth.deposit{value: depositAmount}();

        vm.prank(user1);
        weth.transfer(user2, transferAmount);

        assertEq(weth.balanceOf(user1), 0);
        assertEq(weth.balanceOf(user2), transferAmount);
    }

    function test_ApproveSetAllowance() public {
        // 1. call weth.approve();
        // 2. assert allowance has been set
        uint256 approveAmount = 1 ether;

        vm.prank(user1);
        weth.approve(user2, approveAmount);

        assertEq(weth.allowance(user1, user2), approveAmount);
    }

    function test_TransferFromCanUseAllowance() public {
        // 1. deposit 1 ether to user1 WETH account
        // 2. appove user2 to spend 1 WETH
        // 3. transferFrom 1 WETH from user1 to user2
        uint256 depositAmount = 1 ether;
        uint256 approveAmount = 1 ether;
        uint256 transferAmount = 1 ether;

        vm.prank(user1);
        weth.deposit{value: depositAmount}();

        vm.prank(user1);
        weth.approve(user2, approveAmount);

        vm.prank(user2);
        weth.transferFrom(user1, user2, transferAmount);

        assertEq(weth.balanceOf(user2), transferAmount);
    }

    function test_DeductAllowanceAfterTransferFrom() public {
        // 1. deposit 1 ether to user1 WETH account
        // 2. appove user2 to spend 1 WETH
        // 3. transferFrom 1 WETH from user1 to user2
        uint256 depositAmount = 1 ether;
        uint256 approveAmount = 1 ether;
        uint256 transferAmount = 1 ether;

        vm.prank(user1);
        weth.deposit{value: depositAmount}();

        vm.prank(user1);
        weth.approve(user2, approveAmount);

        vm.prank(user2);
        weth.transferFrom(user1, user2, transferAmount);

        assertEq(weth.allowance(user1, user2), 0);
    }

    function test_Value0TransferEmitTransferEvent() public {
        // 1. declare Transfer event we expect to emit
        // 2. pretend we are user 1 and call transfer with 0 value
        uint256 transferAmount = 0;

        vm.expectEmit();
        emit Transfer(user1, user2, transferAmount);

        vm.prank(user1);
        weth.transfer(user2, transferAmount);
    }

    function test_RevertIf_TransferNotEnoughBalance() public {
        // 1. declare expect to revert on next call
        // 2. pretend we are user1 and call transfer with no balance in WETH
        uint256 transferAmount = 1 ether;
        vm.expectRevert();

        vm.prank(user1);
        weth.transfer(user2, transferAmount);
    }

    function test_ReceiveBehavelikeDeposit() public {
        // 1. declare Deposit event we expect to emit
        // 2. pretend we are user1, perform low level call with value = 1 ether
        // 3. assert balanceOf(user1)
        // 4. assert contract receive 1 ether
        uint256 depositAmount = 1 ether;

        vm.expectEmit();
        emit Deposit(user1, depositAmount);

        vm.prank(user1);
        (bool success,) = address(weth).call{value: depositAmount}("");

        assertTrue(success);
        assertEq(weth.balanceOf(user1), depositAmount);
        assertEq(address(weth).balance, depositAmount);
        assertEq(weth.totalSupply(), depositAmount);
    }

    function test_RevertIf_LowLevelCallWithNoFallBack() public {
        // We haven't implement fallback in Weth,
        // so low level call with data should revert
        uint256 callValue = 1 ether;

        vm.prank(user1);
        (bool success,) = address(weth).call{value: callValue}("0xAA");
        assertEq(success, false);
    }
}
