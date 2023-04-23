// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.6;

import "forge-std/Test.sol";


interface IBYAC {
    function mintApe(uint numberOfTokens) external payable;
    function balanceOf(address owner) external view returns (uint256 balance);
}

contract BYACTest is Test {
    string public RPC_URL = "https://eth-mainnet.g.alchemy.com/v2/Ea1NmKEyxzz-p3O_4WZFu5apdNXGtV0l";
    IBYAC iBYAC;
    address user1 = address(1);
    
    function setUp() public {
        uint256 forkId = vm.createFork(RPC_URL, 12299047);
        vm.selectFork(forkId);
        assertEq(block.number, 12299047);
        iBYAC = IBYAC(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);
        vm.deal(user1, 8 ether);
    }

    function testMint() public {
        vm.startPrank(user1);
        uint256 oldBalance = address(iBYAC).balance;
        assertEq(iBYAC.balanceOf(user1), 0);
        for(int i = 0; i < 5; i++){
            iBYAC.mintApe{value: 1.6 ether}(20);
        }
        uint256 newBalance = address(iBYAC).balance;
        assertEq(oldBalance + 8 ether, newBalance);
        assertEq(iBYAC.balanceOf(user1), 100);
        vm.stopPrank();
        
    }
}
