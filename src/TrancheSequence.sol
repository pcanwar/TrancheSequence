// SPDX-License-Identifier:  BSD 3
pragma solidity ^0.8.0;

/**
 * @title Tranche Sequence
 * @author Anwar (@pcanw)
 * @custom:contact ipcanw@gmail.com
 *
 * @dev Library for managing time-based tranches.
 * that gets collected every period of time.
 *
 * This is a useful library that can contain multiple hierarchies of timestamps.
 *
 */

library TrancheSequence {
    // Define a custom error for when an extension is not allowed
    error NotExtendable();

    // Define the different time units
    enum TimeUnit {
        Minutes,
        Hours,
        Days,
        Weeks
    }

    // Structure for the library
    struct Data {
        uint64 startTime;
        uint64 endTime;
        uint64 tranche;
        uint64 extendTimeSequence;
    }

    ////////////////////////
    // Utility functions
    ////////////////////////

    /**
     * @dev Convert time units to seconds.
     */
    function convertTimeUnitToSeconds(
        TimeUnit timeUnit
    ) private pure returns (uint64) {
        uint64 timeUint = 0;
        if (timeUnit == TimeUnit.Minutes) {
            timeUint = 1 minutes;
        } else if (timeUnit == TimeUnit.Hours) {
            timeUint = 1 hours;
        } else if (timeUnit == TimeUnit.Days) {
            timeUint = 1 days;
        } else if (timeUnit == TimeUnit.Weeks) {
            timeUint = 1 weeks;
        } else {
            revert("Invalid TimeUnit provided.");
        }
        return timeUint;
    }

    ////////////////////////
    // Update functions
    ////////////////////////

    /**
     * @dev Update Tranche Period: to update the tranche period,
     * in case there's a need to change the tranche duration after the library has been deployed.
     */
    function updateTranchePeriod(
        Data storage self,
        uint24 newTranchePeriod
    ) internal {
        self.tranche = newTranchePeriod;
    }

    /**
     * @dev Update Extend Time Sequence: to update the extend time sequence,
     * allowing the contract administrator to change the time sequence after deployment.
     */
    function updateExtendSequence(
        Data storage self,
        uint64 newExtendSequence,
        TimeUnit timeUnit
    ) internal {
        uint64 time = convertTimeUnitToSeconds(timeUnit);
        self.extendTimeSequence = newExtendSequence * time;
    }

    ////////////////////////
    // Getter functions
    ////////////////////////

    /**
     * @dev Get the tranche of days
     */
    function getTrancheDays(Data storage self) internal view returns (uint64) {
        return self.tranche;
    }

    /**
     * @dev Get the extend time sequence.
     */
    function getExtendTimeSequence(
        Data storage self
    ) internal view returns (uint64) {
        return self.extendTimeSequence;
    }

    /**
     * @dev Get the remaining time until the next milestone:
     * @return remaining time in the current milestone.
     * which can be useful for displaying the time left before the milestone expires.
     */
    function getRemainingTime(
        Data storage self
    ) internal view returns (uint64) {
        if (isMilestoneExpired(self)) {
            return 0;
        }
        return self.endTime - uint64(block.timestamp);
    }

    /**
     * @dev Get Next Milestone Timestamp:
     * @return the timestamp for the next milestone,
     * which can be helpful for displaying upcoming milestones.
     */
    function getNextMilestoneTimestamp(
        Data storage self
    ) internal view returns (uint64) {
        if (isMilestoneExpired(self)) {
            uint64 currentTime = uint64(block.timestamp);
            uint64 timeSinceLastMilestone = currentTime - self.endTime;
            uint64 missedMilestones = timeSinceLastMilestone / self.tranche;
            return self.endTime + self.tranche * (missedMilestones + 1);
        }
        return self.endTime + self.tranche;
    }

    /**
     @dev Get the number of missed milestones.
     @return the number of missed milestones,
     * which can be helpful for tracking purposes.
     */
    function getMissedMilestonesCount(
        Data storage self
    ) internal view returns (uint64) {
        if (!isMilestoneExpired(self)) {
            return 0;
        }
        uint64 currentTime = uint64(block.timestamp);
        uint64 timeSinceLastMilestone = currentTime - self.endTime;
        return timeSinceLastMilestone / self.tranche;
    }

    ////////////////////////////////////////////////
    // Initialization and modification functions
    ////////////////////////////////////////////////

    /**
     * @dev Initialize with Custom Start Time: A function to initialize the milestone with a custom start time instead of the current block timestamp.
     * This can be helpful if you want to start the milestones from a specific time in the past or future.
     */
    function initMileStoneWithCustomStartTime(
        Data storage self,
        uint64 customStartTime,
        TimeUnit timeUnit
    ) internal {
        require(self.tranche > 0 && customStartTime <= block.timestamp);
        uint64 tranche = self.tranche * convertTimeUnitToSeconds(timeUnit);
        self.startTime = customStartTime;
        self.endTime = tranche + customStartTime;
        self.tranche = tranche;
    }

    /**
     * @dev Init MileStone
     *
     * @notice this should be run at the smart contract constructor and also after reset the milestone
     */
    function initMileStone(Data storage self, TimeUnit timeUnit) internal {
        require(self.tranche > 0 && self.startTime <= block.timestamp);
        uint64 currentTime = uint64(block.timestamp);
        uint64 tranche = self.tranche * convertTimeUnitToSeconds(timeUnit);
        self.startTime = currentTime;
        self.endTime = currentTime + tranche;
        self.tranche = tranche;
    }

    /**
     * @dev Increase MileStone based on the exsiting MileStone in the contract.
     */

    function increaseMileStone(Data storage self) internal {
        if (!isExtandable(self)) revert NotExtendable();
        uint64 currentTime = self.endTime;
        uint64 newStartTime = currentTime;
        uint64 newEndTime = self.tranche +
            currentTime +
            getElapsedExcessTime(self);
        self.startTime = newStartTime;
        self.endTime = newEndTime;
    }

    function increaseGapMileStone(Data storage self) internal {
        if (!isExtandable(self)) {
            revert("Milestone is not extendable.");
        }

        if (self.tranche == 0) {
            revert("Tranche is not set.");
        }

        uint64 currentTime = uint64(block.timestamp);
        uint64 timeSinceLastMilestone = currentTime - self.endTime;
        uint64 missedMilestones = timeSinceLastMilestone / self.tranche;
        uint64 extraTime = timeSinceLastMilestone % self.tranche;

        self.startTime = self.endTime + extraTime;
        self.endTime = self.startTime + self.tranche * (missedMilestones + 1);
    }

    /**
     * @dev GForce Increase Milestone: A function to force an increase in the milestone, regardless of whether it's currently extendable or not.
     * This can be useful in cases where you need to advance the milestone manually.
     */
    function forceIncreaseMilestone(Data storage self) internal {
        if (self.tranche == 0) {
            revert("Tranche is not set");
        }

        uint64 currentTime = uint64(block.timestamp);
        if (currentTime <= self.endTime) {
            revert("Milestone is not yet expired.");
        }

        uint64 timeSinceLastMilestone = currentTime - self.endTime;
        uint64 missedMilestones = timeSinceLastMilestone / self.tranche;
        uint64 extraTime = timeSinceLastMilestone % self.tranche;

        self.startTime = self.endTime + extraTime;
        self.endTime = self.startTime + self.tranche * (missedMilestones + 1);
    }

    /**
     * @dev renew the mile timestamp sequence.
     * unused since we continue the milestone of the project.
     */
    function renewMileStone(Data storage self) internal {
        if (!isExtandable(self)) revert NotExtendable();
        uint64 currentTime = self.endTime;
        uint64 tranche = self.tranche;
        self.startTime = currentTime;
        self.endTime = tranche + currentTime;
    }

    ////////////////////////
    // Query functions
    ////////////////////////

    /**
     * @dev allow you to query the milestone info for any specific index.
     */
    function getMilestoneAtIndex(
        Data storage self,
        uint64 index
    ) internal view returns (uint64, uint64) {
        uint64 startTime = self.startTime + (index * self.tranche);
        uint64 endTime = startTime + self.tranche;
        return (startTime, endTime);
    }

    function getMilestoneAtIndex(
        Data storage self,
        uint64 index,
        bool directionForward
    ) internal view returns (uint64, uint64) {
        uint64 startTime;
        if (directionForward) {
            startTime = self.startTime + (index * self.tranche);
        } else {
            startTime = self.endTime - ((index + 1) * self.tranche);
        }
        uint64 endTime = startTime + self.tranche;
        return (startTime, endTime);
    }

    /**
     * @dev
     * @return the total number of milestones, both completed and pending,
     * based on the current state of the library.
     */
    function getTotalMilestones(
        Data storage self
    ) internal view returns (uint64) {
        uint64 currentTime = uint64(block.timestamp);
        uint64 elapsedTranches = (currentTime - self.startTime) / self.tranche;
        return elapsedTranches + 1;
    }

    /**
     * @return the number of completed milestones based on the current state of the library.
     */
    function getCompletedMilestonesCount(
        Data storage self
    ) internal view returns (uint64) {
        uint64 currentTime = uint64(block.timestamp);
        if (currentTime <= self.startTime) {
            return 0;
        }
        uint64 elapsedTranches = (currentTime - self.startTime) / self.tranche;
        return elapsedTranches;
    }

    /**
     * @dev get the missing time at the end of the MileStone if there was no extended
     * it works only if there is no extanded occur or missing to increase the milestone..
     *
     */
    function getElapsedExcessTime(
        Data storage self
    ) private view returns (uint64) {
        uint64 timestamp = uint64(block.timestamp);
        if (self.endTime < timestamp) {
            uint64 _b = timestamp - self.endTime;
            return _b;
        } else {
            return 0;
        }
    }

    ////////////////////////
    // Helper functions
    ////////////////////////

    /**
     * @return List all missing timestamps since the last completed milestone
     */
    function listMissingTimestamps(
        Data storage self
    ) internal view returns (uint64[] memory) {
        if (!isMilestoneExpired(self)) {
            return new uint64[](0);
        }

        uint64 currentTime = uint64(block.timestamp);
        uint64 timeSinceLastMilestone = currentTime - self.endTime;
        uint64 missedMilestones = timeSinceLastMilestone / self.tranche;

        uint64[] memory missingTimestamps = new uint64[](
            (missedMilestones + 1) * 2
        );
        uint64 currentStart = self.endTime;

        for (uint64 i = 0; i <= missedMilestones; i++) {
            missingTimestamps[i * 2] = currentStart;
            missingTimestamps[i * 2 + 1] = currentStart + self.tranche;
            currentStart += self.tranche;
        }

        return missingTimestamps;
    }

    /**
     * @dev reset mile sequence .
     *
     */
    function resetMileStone(Data storage self) internal {
        self.endTime = 0;
        self.startTime = 0;
        self.tranche = 0;
    }

    /**
     * @return MileStone's start timer and end timer.
     */
    function currentMile(
        Data storage self
    ) internal view returns (uint64, uint64) {
        return (self.startTime, self.endTime);
    }

    /**
     * @return the current start timer.
     */

    function currentStartMile(
        Data storage self
    ) internal view returns (uint64) {
        return (self.startTime);
    }

    /**
     * @return the current end timer.
     */
    function currentEndtMile(Data storage self) internal view returns (uint64) {
        return (self.endTime);
    }

    /**
     * @return a boolean if current time is in the sequence
     */
    function isCurrentMilestone(
        Data storage self
    ) internal view returns (bool) {
        return
            self.startTime < block.timestamp && self.endTime > block.timestamp;
    }

    /**
     * @return a boolean if mile sequence is started
     */
    function isMilestoneStarted(
        Data storage self
    ) internal view returns (bool) {
        return self.startTime > 0;
    }

    /**
     * @return a boolean if one slice of a sequence is ended
     */
    function isMilestoneExpired(
        Data storage self
    ) internal view returns (bool) {
        return self.endTime <= block.timestamp;
    }

    /**
     * @return a boolean if a time sequence can be extanded
     */
    function isExtandable(Data storage self) internal view returns (bool) {
        if (!isMilestoneStarted(self)) {
            return false;
        }
        uint64 extendTimeSequence = self.extendTimeSequence;
        return self.endTime - extendTimeSequence <= block.timestamp;
    }
}
