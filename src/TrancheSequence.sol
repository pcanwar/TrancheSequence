// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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
    // error NotExtendable();

    // Define the different time units
    enum TimeUnit {
        Minutes,
        Hours,
        Days,
        Weeks
    }

    // Structure for the library
    struct Data {
        uint256 startTime;
        uint256 endTime;
        uint256 tranche;
        uint256 extendTimeSequence;
    }

    // struct Initialization {
    //     bool isStarted;
    // }

    ////////////////////////
    // Utility functions
    ////////////////////////

    /**
     * @dev Convert time units to seconds.
     */
    function convertTimeUnitToSeconds(
        TimeUnit timeUnit
    ) private pure returns (uint256) {
        // uint256 timeUint = 0;
        if (timeUnit == TimeUnit.Minutes) {
            return 1 minutes;
        } else if (timeUnit == TimeUnit.Hours) {
            return 1 hours;
        } else if (timeUnit == TimeUnit.Days) {
            return 1 days;
        } else if (timeUnit == TimeUnit.Weeks) {
            return 1 weeks;
        }
        revert("Invalid TimeUnit provided.");

        // return timeUint;
    }

    ////////////////////////////////////////////////
    // Initialization and modification functions
    ////////////////////////////////////////////////

    /**
     * @dev Init MileStone
     *
     * @notice this should be run in the smart contract constructor and also after reset the milestone
     */
    function initMileStone(
        Data storage self, // Initialization storage ones
        uint256 newTranchePeriod,
        TimeUnit trancheTimeUnit,
        uint256 newExtendSequence,
        TimeUnit extendTimeUnit
    ) internal {
        // require(!ones.isStarted);
        // require(self.tranche > 0 && self.startTime <= block.timestamp);

        updateTranchePeriod(self, newTranchePeriod, trancheTimeUnit);
        updateExtendSequence(self, newExtendSequence, extendTimeUnit);
        // ones.isStarted = true;
        uint256 currentTime = block.timestamp;
        self.startTime = currentTime;
        self.endTime = currentTime + self.tranche;
    }

    /**
     * @dev Initialize with Custom Start Time: A function to initialize the milestone with a custom start time instead of the current block timestamp.
     * This can be helpful if you want to start the milestones from a specific time in the past or future.
     */
    function initMileStoneWithCustomStartTime(
        Data storage self,
        uint64 newTranchePeriod,
        TimeUnit trancheTimeUnit,
        uint64 newExtendSequence,
        TimeUnit extendTimeUnit,
        uint64 customStartTime
    ) internal {
        // require(!ones.isStarted);
        require(
            self.tranche > 0 && customStartTime <= block.timestamp,
            "Invalid start time or tranche"
        );

        require(newTranchePeriod > 0, "Tranche period must be positive");
        require(
            uint(trancheTimeUnit) <= 3,
            "Invalid time unit for tranche period"
        );
        require(newExtendSequence > 0, "Extend sequence must be positive");
        require(
            uint(extendTimeUnit) <= 3,
            "Invalid time unit for extend sequence"
        );
        require(
            self.tranche > 0 && customStartTime <= block.timestamp,
            "Invalid start time or tranche"
        );

        updateTranchePeriod(self, newTranchePeriod, trancheTimeUnit);
        updateExtendSequence(self, newExtendSequence, extendTimeUnit);

        self.startTime = customStartTime;
        self.endTime = self.tranche + customStartTime;
    }

    /**
     * @dev Increase MileStone based on the exsiting MileStone in the contract.
     */

    function increaseMileStone(Data storage self) internal {
        // if (!isExtandable(self)) revert NotExtendable();
        require(isExtandable(self), "Not Extandable");
        uint256 currentTime = self.endTime;
        uint256 newStartTime = currentTime + getElapsedExcessTime(self);
        uint256 newEndTime = self.tranche + newStartTime;
        self.startTime = newStartTime;
        self.endTime = newEndTime;
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
        uint256 newTranchePeriod,
        TimeUnit timeUnit
    ) private {
        require(newTranchePeriod > 0, "Tranche period must be positive");
        require(uint(timeUnit) <= 3, "Invalid time unit for tranche period");
        self.tranche = newTranchePeriod * convertTimeUnitToSeconds(timeUnit);
    }

    /**
     * @dev Update Extend Time Sequence: to update the extend time sequence,
     * allowing the contract administrator to change the time sequence after deployment.
     */
    function updateExtendSequence(
        Data storage self,
        uint256 newExtendSequence,
        TimeUnit timeUnit
    ) private {
        require(newExtendSequence > 0, "Extend sequence must be positive");
        require(uint(timeUnit) <= 3, "Invalid time unit for extend sequence");
        uint256 time = convertTimeUnitToSeconds(timeUnit);
        self.extendTimeSequence = newExtendSequence * time;
    }

    ////////////////////////
    // Getter functions
    ////////////////////////

    /**
     * @dev Get the tranche of days
     */
    function getTrancheDays(Data storage self) internal view returns (uint256) {
        return self.tranche;
    }

    /**
     * @dev Get the extend time sequence.
     */
    function getExtendTimeSequence(
        Data storage self
    ) internal view returns (uint256) {
        return self.extendTimeSequence;
    }

    /**
     * @dev Get the remaining time until the next milestone:
     * @return remaining time in the current milestone.
     * which can be useful for displaying the time left before the milestone expires.
     */
    function getRemainingTime(
        Data storage self
    ) internal view returns (uint256) {
        if (isMilestoneExpired(self)) {
            return 0;
        }
        uint256 remainingTime = 0;
        if (self.endTime > block.timestamp) {
            remainingTime = self.endTime - block.timestamp;
            if (isExtandable(self) && remainingTime < self.extendTimeSequence) {
                remainingTime += self.extendTimeSequence;
            }
        }

        return remainingTime;
        // return self.endTime - uint256(block.timestamp);
    }

    /**
     * @dev Get Next Milestone Timestamp:
     * @return the timestamp for the next milestone,
     * which can be helpful for displaying upcoming milestones.
     */
    function getNextMilestoneTimestamp(
        Data storage self
    ) internal view returns (uint256) {
        if (isMilestoneExpired(self)) {
            uint256 currentTime = uint256(block.timestamp);
            uint256 timeSinceLastMilestone = currentTime - self.endTime;
            uint256 missedMilestones = timeSinceLastMilestone / self.tranche;
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
    ) internal view returns (uint256) {
        if (!isMilestoneExpired(self)) {
            return 0;
        }
        uint256 currentTime = uint256(block.timestamp);
        uint256 timeSinceLastMilestone = currentTime - self.endTime;
        return timeSinceLastMilestone / self.tranche;
    }

    ////////////////////////
    // Query functions
    ////////////////////////

    /**
     * @dev allow you to query the milestone info for any specific index.
     */
    function getMilestoneAtIndexForward(
        Data storage self,
        uint256 index
    ) internal view returns (uint256, uint256) {
        uint256 startTime = self.startTime +
            (index * self.tranche) +
            getElapsedExcessTime(self);
        uint256 endTime = startTime + self.tranche;
        if (endTime <= block.timestamp) {
            uint256 missedMilestones = (uint256(block.timestamp) - endTime) /
                self.tranche;
            startTime += (missedMilestones + 1) * self.tranche;
            endTime = startTime + self.tranche;
        }
        return (startTime, endTime);
    }

    function getNextMilestoneTimestampFrom(
        uint256 startTime,
        uint256 tranche
    ) private view returns (uint256) {
        uint256 currentTime = uint256(block.timestamp);
        if (startTime <= currentTime) {
            uint256 timeSinceStart = currentTime - startTime;
            uint256 milestonesPassed = timeSinceStart / tranche;
            startTime += (milestonesPassed + 1) * tranche;
        }
        return startTime;
    }

    function getMilestoneAtIndexBackward(
        Data storage self,
        uint256 index
    ) internal view returns (uint256, uint256) {
        uint256 elapsedExcessTime = getElapsedExcessTime(self);
        uint256 endTime = self.endTime -
            (index * self.tranche) -
            elapsedExcessTime;
        uint256 startTime = endTime - self.tranche;

        // Check if the milestone has been extended
        if (isMilestoneExpired(self)) {
            uint256 excessTime = getElapsedExcessTime(self);
            startTime -= excessTime;
            endTime = startTime + self.tranche;
        }

        // Adjust start and end times to stay within contract bounds
        if (startTime < self.startTime) {
            uint256 missedMilestones = (self.startTime - startTime) /
                self.tranche;
            endTime -= missedMilestones * self.tranche;
            startTime = endTime - self.tranche;
        } else if (endTime > self.endTime) {
            uint256 missedMilestones = (endTime - self.endTime) / self.tranche;
            startTime += missedMilestones * self.tranche;
            endTime = startTime + self.tranche;
        }

        return (startTime, endTime);
    }

    /**
     * @dev
     * @return the total number of milestones, both completed and pending,
     * based on the current state of the library.
     */
    function getTotalMilestones(
        Data storage self
    ) internal view returns (uint256) {
        uint256 currentTime = uint256(block.timestamp);
        uint256 elapsedTranches = (currentTime - self.startTime) / self.tranche;
        return elapsedTranches + 1;
    }

    /**
     * @return the number of completed milestones based on the current state of the library.
     */
    function getCompletedMilestonesCount(
        Data storage self
    ) internal view returns (uint256) {
        uint256 currentTime = uint256(block.timestamp);
        if (currentTime <= self.startTime) {
            return 0;
        }
        uint256 elapsedTranches = (currentTime - self.startTime) / self.tranche;
        return elapsedTranches;
    }

    /**
     * @dev get the missing time at the end of the MileStone if there was no extended
     * it works only if there is no extanded occur or missing to increase the milestone..
     *
     */
    function getElapsedExcessTime(
        Data storage self
    ) private view returns (uint256) {
        uint256 timestamp = uint256(block.timestamp);
        if (self.endTime < timestamp) {
            uint256 _b = timestamp - self.endTime;
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
    ) internal view returns (uint256[] memory) {
        if (!isMilestoneExpired(self)) {
            return new uint256[](0);
        }

        uint256 currentTime = uint256(block.timestamp);
        uint256 timeSinceLastMilestone = currentTime - self.endTime;
        uint256 missedMilestones = timeSinceLastMilestone / self.tranche;

        uint256[] memory missingTimestamps = new uint256[](
            (missedMilestones + 1) * 2
        );
        uint256 currentStart = self.endTime;

        for (uint256 i = 0; i <= missedMilestones; i++) {
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
    ) internal view returns (uint256, uint256) {
        return (self.startTime, self.endTime);
    }

    /**
     * @return the current start timer.
     */

    function currentStartMile(
        Data storage self
    ) internal view returns (uint256) {
        return (self.startTime);
    }

    /**
     * @return the current end timer.
     */
    function currentEndtMile(
        Data storage self
    ) internal view returns (uint256) {
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
        uint256 extendTimeSequence = self.extendTimeSequence;
        return self.endTime - extendTimeSequence <= block.timestamp;
    }

    ////////////////////////
    // Options functions
    ////////////////////////

    /**
     * @dev GForce Increase Milestone: A function to force an increase in the milestone, regardless of whether it's currently extendable or not.
     * This can be useful in cases where you need to advance the milestone manually.
     */
    function forceIncreaseMilestone(Data storage self) internal {
        if (self.tranche == 0) {
            revert("Tranche is not set");
        }

        uint256 currentTime = uint256(block.timestamp);
        uint256 timeSinceLastMilestone = currentTime - self.endTime;
        uint256 missedMilestones = timeSinceLastMilestone / self.tranche;
        uint256 extraTime = timeSinceLastMilestone % self.tranche;

        self.startTime = self.endTime + extraTime;
        self.endTime = self.startTime + self.tranche * (missedMilestones + 1);
    }

    /**
     * @dev renew the mile timestamp sequence.
     * unused since we continue the milestone of the project.
     */
    function renewMileStone(Data storage self) internal {
        // if (!isExtandable(self)) revert NotExtendable();
        require(isExtandable(self), "Not Extandable Yet");

        uint256 currentTime = self.endTime;
        uint256 tranche = self.tranche;
        self.startTime = currentTime;
        self.endTime = tranche + currentTime;
    }

    function increaseGapMileStone(Data storage self) internal {
        // if (!isExtandable(self)) {
        //     revert("Milestone is not extendable.");
        // }
        require(isExtandable(self), "Not Extandable Yet");

        if (self.tranche == 0) {
            revert("Tranche is not set.");
        }

        uint256 currentTime = uint256(block.timestamp);
        uint256 timeSinceLastMilestone = currentTime - self.endTime;
        uint256 missedMilestones = timeSinceLastMilestone / self.tranche;
        uint256 extraTime = timeSinceLastMilestone % self.tranche;

        self.startTime = self.endTime + extraTime;
        self.endTime = self.startTime + self.tranche * (missedMilestones + 1);
    }
}
