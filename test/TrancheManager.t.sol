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
        uint64 tranch = 3;
        uint64 abletoExtendAfter = 2;
        vm.prank(userA);

        tranchManager = new TrancheManager(
            tranch,
            abletoExtendAfter,
            TrancheSequence.TimeUnit.Minutes,
            TrancheSequence.TimeUnit.Minutes
        );
    }

    function testCurrentMile() public view {
        (uint64 startTime, uint64 endTime) = tranchManager.currentMile();
        console.log("start Time", startTime);
        console.log("End Time", endTime);

        (uint64 a, uint64 b, , ) = tranchManager.trancheData();
        console.log(a, b);
    }

    function testInitializeExample() public {
        vm.prank(userA);
        tranchManager.initializeExample(1);
    }

    function testRunUserCase() public {
        vm.prank(userA);
        tranchManager.run();
    }
}

// contract TranchManagerIncreaseTime is BaseTrancheManagerTest {}
