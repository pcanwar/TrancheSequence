// SPDX-License-Identifier:  BSD 3
pragma solidity ^0.8.0;

/**
 * @title Tranche Sequence
 * @author Anwar (@pcanw)
 * @custom:contact ipcanw@gmail.com
 *
 * @dev The Mile Sequence is a sequence of opportunities for making payments (e.g., rewards)
 * that gets collected every period of time.
 * Each time period is like a slice.
 *
 * Readme
 * This is a useful library that can contain multiple hierarchies of timestamps.
 *
 * TODO:
 *  - add a list of the time in the library
 * - Allow admin to increase/control time if needed in the smart contract.
 */

library TrancheSequence {
    error NotExtandable();

    enum TimeUnit {
        Minutes,
        Hours,
        Days,
        Weeks
    }

    function timeUnitMileStone(
        Data storage self,
        TimeUnit timeUnit
    ) internal view returns (uint64) {
        uint64 tranche;
        if (timeUnit == TimeUnit.Minutes) {
            tranche = self.tranche * 1 minutes;
        } else if (timeUnit == TimeUnit.Hours) {
            tranche = self.tranche * 1 hours;
        } else if (timeUnit == TimeUnit.Days) {
            tranche = self.tranche * 1 days;
        } else if (timeUnit == TimeUnit.Weeks) {
            tranche = self.tranche * 1 weeks;
        } else {
            revert("Invalid time unit provided.");
        }
        return tranche;
    }

    struct Data {
        uint64 startTime;
        uint64 endTime;
        uint64 tranche;
        uint24 extendTimeSequence;
    }

    ////////////////////////
    // Update functions
    ////////////////////////

    /**
     * @dev Update Tranche Period: Set a function to update the tranche period,
     * in case there's a need to change the tranche duration after the library has been deployed.
     */
    function updateTranchePeriod(
        Data storage self,
        uint24 newTranche
    ) internal {
        self.tranche = newTranche;
    }

    /**
     * @dev Update Extend Time Sequence: Set a function to update the extend time sequence,
     * allowing the contract administrator to change the time sequence after deployment.
     */
    function updateExtendSequence(
        Data storage self,
        uint24 extendTimeSequence
    ) internal {
        self.extendTimeSequence = extendTimeSequence;
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
     * @dev Get the tranche of days
     */
    function getExtendTimeSequence(
        Data storage self
    ) internal view returns (uint64) {
        return self.extendTimeSequence;
    }

    /**
     * @dev Get Next Milestone Timestamp: A function to return the timestamp for the next milestone,
     * which can be helpful for displaying upcoming milestones.
     */
    function getRemainingTime(
        Data storage self
    ) internal view returns (uint64) {
        if (isMileExpired(self)) {
            return 0;
        }
        return self.endTime - uint64(block.timestamp);
    }

    /**
     * @dev Get Remaining Time: to get the remaining time in the current milestone,
     * which can be useful for displaying the time left before the milestone expires.
     */
    function getNextMilestoneTimestamp(
        Data storage self
    ) internal view returns (uint64) {
        if (isMileExpired(self)) {
            uint64 currentTime = uint64(block.timestamp);
            uint64 timeSinceLastMilestone = currentTime - self.endTime;
            uint64 missedMilestones = timeSinceLastMilestone / self.tranche;
            return self.endTime + self.tranche * (missedMilestones + 1);
        }
        return self.endTime + self.tranche;
    }

    /**
     * @dev Get Missed Milestones Count: A function to return the number of missed milestones,
     * which can be helpful for tracking purposes.
     */
    function getMissedMilestonesCount(
        Data storage self
    ) internal view returns (uint64) {
        if (!isMileExpired(self)) {
            return 0;
        }
        uint64 currentTime = uint64(block.timestamp);
        uint64 timeSinceLastMilestone = currentTime - self.endTime;
        return timeSinceLastMilestone / self.tranche;
    }

    ////////////////////////
    // Initialization and modification functions
    ////////////////////////

    /**
     * @dev Initialize with Custom Start Time: A function to initialize the milestone with a custom start time instead of the current block timestamp.
     * This can be helpful if you want to start the milestones from a specific time in the past or future.
     */
    function initMileStoneWithCustomStartTime(
        Data storage self,
        uint64 customStartTime,
        TimeUnit timeUnit
    ) internal {
        require(self.tranche > 0 && customStartTime < block.timestamp);
        uint64 tranche = timeUnitMileStone(self, timeUnit);
        self.startTime = customStartTime;
        self.endTime = ((tranche) + customStartTime);
        self.tranche = tranche;
    }

    /**
     * @dev Init MileStone
     *
     * @notice this should be run at the smart contract constructor and also after reset the milestone
     */
    function initMileStone(Data storage self) internal {
        require(self.tranche > 0 && self.startTime < block.timestamp);
        uint64 currentTime = uint64(block.timestamp);
        uint64 tranche = self.tranche * 1 days;
        self.startTime = currentTime;
        self.endTime = currentTime + tranche;
        self.tranche = tranche;
    }

    /**
     * @dev Increase MileStone based on the exsiting MileStone in the contract.
     */

    function increaseMileStone(Data storage self) internal {
        if (!isExtandable(self)) NotExtandable;
        uint64 currentTime = self.endTime;
        uint64 newStartTime = currentTime;
        uint64 newEndTime = self.tranche + currentTime + passTimer(self);
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
     * @dev Pass the missing time at the end of the MileStone if there was no extended
     * it works only if there is no extanded occur or missing to increase the milestone..
     *
     */
    function passTimer(Data storage self) private view returns (uint64) {
        uint64 timestamp = uint64(block.timestamp);
        if (self.endTime < timestamp) {
            uint64 _b = timestamp - self.endTime;
            return _b;
        } else {
            return 0;
        }
    }

    /**
     * @dev renew the mile timestamp sequence.
     * unused since we continue the milestone of the project.
     */
    function renewMileStone(Data storage self) internal {
        if (!isExtandable(self)) NotExtandable;
        uint64 currentTime = self.endTime;
        uint64 tranche = self.tranche * 1 days;
        self.startTime = currentTime;
        self.endTime = tranche + currentTime;
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
     * @dev Returns MileStone's start timer and end timer.
     */
    function currentMile(
        Data storage self
    ) internal view returns (uint64, uint64) {
        return (self.startTime, self.endTime);
    }

    /**
     * @dev Returns the current start timer.
     */

    function currentStartMile(
        Data storage self
    ) internal view returns (uint64) {
        return (self.startTime);
    }

    /**
     * @dev Returns the current end timer.
     */
    function currentEndtMile(Data storage self) internal view returns (uint64) {
        return (self.endTime);
    }

    ////////////////////////
    // Helper functions
    ////////////////////////

    /**
     * @dev Returns a boolean if current time is in the sequence
     */
    function isCurrentMile(Data storage self) internal view returns (bool) {
        return
            self.startTime < block.timestamp && self.endTime > block.timestamp;
    }

    /**
     * @dev Returns a boolean if mile sequence is started
     */
    function isMileStarted(Data storage self) internal view returns (bool) {
        return self.startTime > 0;
    }

    /**
     * @dev Returns a boolean if one slice of a sequence is ended
     */
    function isMileExpired(Data storage self) internal view returns (bool) {
        return self.endTime <= block.timestamp;
    }

    /**
     * @dev Returns a boolean if a time sequence can be extanded
     */
    function isExtandable(Data storage self) internal view returns (bool) {
        if (!isMileStarted(self)) {
            return false;
        }
        uint24 extendTimeSequence = self.extendTimeSequence * 1 days;
        return self.endTime - extendTimeSequence <= block.timestamp;
    }
}
