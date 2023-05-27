// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TrancheManager.sol";
import "forge-std/console.sol";

contract BaseTrancheManagerTest is Test {
    TrancheManager public tranchManager;
    address public userA;
    uint _limit = 1;

    function setUp() public virtual {
        userA = address(uint160(uint256(keccak256(abi.encodePacked("userA")))));
        vm.label(userA, "userA");
        uint256 tranch = 3;
        uint256 abletoExtendAfter = 2;
        vm.prank(userA);

        tranchManager = new TrancheManager(
            tranch,
            abletoExtendAfter,
            TrancheSequence.TimeUnit.Hours,
            TrancheSequence.TimeUnit.Days
        );
    }

    function testCurrentMile() public view {
        (uint256 startTime, uint256 endTime) = tranchManager.currentMile();
        console.log("start Time", startTime);
        console.log("End Time", endTime);

        (uint256 a, uint256 b, , ) = tranchManager.trancheData();
        console.log(a, b);
    }

    function testInitializeExample() public {
        vm.prank(userA);
        tranchManager.initializeExample(_limit);
    }

    function testRunUserCase() public {
        (uint256 startTime, , , ) = tranchManager.trancheData();
        vm.prank(userA);
        tranchManager.initializeExample(_limit);
        vm.prank(userA);
        tranchManager.run();
        vm.prank(userA);
        uint balance = tranchManager.balance(startTime);
        console.log("balance : ", balance);
    }
}

// contract TranchManagerIncreaseTime is BaseTrancheManagerTest {}
