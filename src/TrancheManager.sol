// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./TrancheSequence.sol";

/**
 * @title Example
 * @author Anwar (@pcanw)
 *
 * @dev
 *
 */

// to do: retrun limit per swop and return max by claim

contract TrancheManager {
    uint public limitations;

    // struct paymentPerMileStone {
    //     uint tokens;
    //     uint endTime;
    //     bool isRewarded;
    // }

    mapping(address => mapping(uint => uint)) public paymentPerMileStone;
    using TrancheSequence for TrancheSequence.Data;
    TrancheSequence.Data public trancheData;

    constructor(
        uint256 newTranchePeriod,
        uint256 newExtendSequence,
        TrancheSequence.TimeUnit timeUnitT,
        TrancheSequence.TimeUnit timeUnit2
    ) {
        // require(newTranchePeriod > 0 && newExtendSequence > 0, "ZERO");
        // trancheData.updateTranchePeriod(newTranchePeriod, timeUnit);
        // trancheData.updateExtendSequence(newExtendSequence, timeUnit);
        trancheData.initMileStone(
            newTranchePeriod,
            timeUnitT,
            newExtendSequence,
            timeUnit2
        );
    }

    function restart(
        uint256 newTranchePeriod,
        uint256 newExtendSequence,
        TrancheSequence.TimeUnit timeUnitT,
        TrancheSequence.TimeUnit timeUnit2
    ) external {
        // require(newTranchePeriod > 0 && newExtendSequence > 0, "ZERO");
        // trancheData.updateTranchePeriod(newTranchePeriod, timeUnit);
        // trancheData.updateExtendSequence(newExtendSequence, timeUnit);
        trancheData.initMileStone(
            newTranchePeriod,
            timeUnitT,
            newExtendSequence,
            timeUnit2
        );
    }

    function initializeExample(uint _limit) public {
        require(_limit > 0, "ZERO");
        limitations = _limit;
    }

    // the implemention of a use case
    function run() public {
        extend_();
        uint256 limit = limitations;
        uint256 _start = trancheData.currentStartMile();
        if (paymentPerMileStone[msg.sender][_start] < limit) {
            paymentPerMileStone[msg.sender][_start] += 400;
        }
    }

    function getTrancheDays() public view returns (uint256) {
        return trancheData.getTrancheDays();
    }

    function getExtendTimeSequence() public view returns (uint256) {
        return trancheData.getExtendTimeSequence();
    }

    function getRemainingTime() public view returns (uint256) {
        return trancheData.getRemainingTime();
    }

    function getNextMilestoneTimestamp() public view returns (uint256) {
        return trancheData.getNextMilestoneTimestamp();
    }

    function getMissedMilestonesCount() public view returns (uint256) {
        return trancheData.getMissedMilestonesCount();
    }

    function getTotalMilestones() public view returns (uint256) {
        return trancheData.getTotalMilestones();
    }

    function getCompletedMilestonesCount() public view returns (uint256) {
        return trancheData.getCompletedMilestonesCount();
    }

    /**
     * @dev Returns false if the time is not extandable otherwise increase the MileStone
     */
    function increaseMileStone() public returns (bool) {
        if (trancheData.isExtandable()) {
            trancheData.increaseMileStone();
            return true;
        }
        return false;
    }

    function increaseGapMileStone() public {
        trancheData.increaseGapMileStone();
    }

    function forceIncreaseMilestone() public {
        trancheData.forceIncreaseMilestone();
    }

    function renewMileStone() public {
        trancheData.renewMileStone();
    }

    function listMissingTimestamps() public view returns (uint256[] memory) {
        return trancheData.listMissingTimestamps();
    }

    /**
     * @dev reset all time
     */
    function resetMileStone() public {
        trancheData.resetMileStone();
    }

    /**
     * @dev Returns the current MileStone
     */
    function currentMile() public view returns (uint256, uint256) {
        return trancheData.currentMile();
    }

    function currentStartMile() public view returns (uint256) {
        return trancheData.currentStartMile();
    }

    function currentEndtMile() public view returns (uint256) {
        return trancheData.currentEndtMile();
    }

    function isCurrentMilestone() public view returns (bool) {
        return trancheData.isCurrentMilestone();
    }

    function isMilestoneStarted() public view returns (bool) {
        return trancheData.isMilestoneStarted();
    }

    // function isMilestoneExpired() public view returns (bool) {
    //     return

    /**
     * dev: extend the milestone
     */
    function extend_() public {
        bool _x = increaseMileStone();
        if (_x == true) {
            increaseMileStone();
        }
    }

    function isExtanded() public view returns (bool) {
        return trancheData.isExtandable();
    }
}
