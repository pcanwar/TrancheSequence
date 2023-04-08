// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./openzzeppelin/Counters.sol";
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

    struct rewardMileStone {
        uint tokens;
        uint endTime;
        bool isRewarded;
    }

    mapping(address => mapping(uint => rewardMileStone))
        internal addressToRewardMile;
    using TrancheSequence for TrancheSequence.Data;
    TrancheSequence.Data public trancheData;

    constructor(
        uint64 tranchePeriod,
        uint64 extendTimeSequence,
        TrancheSequence.TimeUnit timeUnit
    ) {
        require(tranchePeriod > 0 && extendTimeSequence > 0, "ZERO");
        trancheData.tranche = tranchePeriod;
        trancheData.extendTimeSequence = extendTimeSequence;
        trancheData.initMileStone(timeUnit);
    }

    function initialize(uint _limit) public {
        require(_limit > 0, "ZERO");
        limitations = _limit;
    }

    function updateTranchePeriod(uint24 newTranchePeriod) public {
        trancheData.updateTranchePeriod(newTranchePeriod);
    }

    function updateExtendSequence(
        uint64 newExtendSequence,
        TrancheSequence.TimeUnit timeUnit
    ) public {
        trancheData.updateExtendSequence(newExtendSequence, timeUnit);
    }

    function getTrancheDays() public view returns (uint64) {
        return trancheData.getTrancheDays();
    }

    function getExtendTimeSequence() public view returns (uint64) {
        return trancheData.getExtendTimeSequence();
    }

    function getRemainingTime() public view returns (uint64) {
        return trancheData.getRemainingTime();
    }

    function getNextMilestoneTimestamp() public view returns (uint64) {
        return trancheData.getNextMilestoneTimestamp();
    }

    function getMissedMilestonesCount() public view returns (uint64) {
        return trancheData.getMissedMilestonesCount();
    }

    function getTotalMilestones() public view returns (uint64) {
        return trancheData.getTotalMilestones();
    }

    function getCompletedMilestonesCount() public view returns (uint64) {
        return trancheData.getCompletedMilestonesCount();
    }

    function getMilestoneAtIndex(
        uint64 index
    ) public view returns (uint64, uint64) {
        return trancheData.getMilestoneAtIndex(index);
    }

    function initMileStoneWithCustomStartTime(
        uint64 customStartTime,
        TrancheSequence.TimeUnit timeUnit
    ) public {
        trancheData.initMileStoneWithCustomStartTime(customStartTime, timeUnit);
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

    function listMissingTimestamps() public view returns (uint64[] memory) {
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
    function currentMile() public view returns (uint64, uint64) {
        return trancheData.currentMile();
    }

    function currentStartMile() public view returns (uint64) {
        return trancheData.currentStartMile();
    }

    function currentEndtMile() public view returns (uint64) {
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

    // swap nfts, there is a fee on each swap but once the nft-swap occur, no need to pay a new fees.
    function swapTokenToToken() public {
        extend_();

        uint64 _start = trancheData.currentStartMile();

        if (addressToRewardMile[msg.sender][_start].tokens < limitations) {
            addressToRewardMile[msg.sender][_start].tokens++;
        }
    }
}
