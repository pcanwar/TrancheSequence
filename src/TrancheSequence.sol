// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Tranche Sequence
 * @author Anwar (@pcanw)ipcanw@gmail.com
 *
 * @dev Mile sequence is a sequence of opportunities for making payment eg.(rewards). It gets collected every period of time.
 * Every time period is like a slice.
 *
 *
 * Readme
 * It is useful library to contain multiple hierarchies timestamp.
 *
 * TODO - add a list of the time in the library
 *      - increase/ control time by admin if it is needed in the smart contract
 */

library TrancheSequence {
    struct Data {
        uint64 startTime;
        uint64 endTime;
        uint64 period;
        uint24 tranche;
        uint24 extendTimeSequence;
    }

    /**
     * @dev Sets the period of days
     */
    function setPeriod(Data storage self, uint64 period) internal {
        self.period = period;
    }

    /**
     * @dev Get the period of days
     */
    function getPeriod(Data storage self) internal view returns (uint64) {
        return self.period;
    }

    /**
     * @dev Sets the tranche of days
     */
    function setTranche(Data storage self, uint24 tranche) internal {
        self.tranche = tranche;
    }

    /**
     * @dev Get the tranche of days
     */
    function getTranche(Data storage self) internal view returns (uint64) {
        return self.tranche;
    }

    /**
     * @dev Sets the extend Time Sequence of days
     */
    function setExtendTimeSequence(Data storage self, uint24 extendTimeSequence)
        internal
    {
        self.extendTimeSequence = extendTimeSequence;
    }

    /**
     * @dev Get the tranche of days
     */
    function getExtendTimeSequence(Data storage self)
        internal
        view
        returns (uint64)
    {
        return self.extendTimeSequence;
    }

    /**
     * @dev Init MileStone
     *
     * @notice this should be run at the smart contract constructor and also after reset the milestone
     */
    function initMileStone(Data storage self) internal {
        require(self.period > 0 && self.startTime < block.timestamp);
        uint64 currentTime = uint64(block.timestamp);
        uint64 reTimer = 0;
        uint64 period = self.period;
        uint24 tranche = self.tranche * 1 days;

        self.startTime = currentTime + reTimer;
        self.endTime = ((tranche * period) + currentTime);
        reTimer = (tranche * period);
    }

    /**
     * @dev Increase MileStone based on the exsiting MileStone in the contract.
     */

    function increaseMileStone(Data storage self) internal {
        require(isExtandable(self), "Not_Extandable");
        uint64 currentTime = self.endTime;
        uint24 tranche = self.tranche;
        uint64 reTimer = 0;
        self.startTime = currentTime + reTimer;
        self.endTime = ((tranche * self.period) +
            currentTime +
            passTimer(self));
        reTimer = (tranche * self.period);
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
        require(isExtandable(self), "UnExtandable");
        uint64 currentTime = self.endTime;
        uint64 reTimer = 0;
        uint24 tranche = self.tranche * 1 days;
        self.startTime = currentTime + reTimer;
        self.endTime = ((tranche * self.period) + currentTime);
        reTimer = (tranche * self.period);
    }

    /**
     * @dev reset mile sequence .
     *
     */
    function resetMileStone(Data storage self) internal {
        self.endTime = 0;
        self.startTime = 0;
        self.period = 0;
    }

    /**
     * @dev Returns MileStone's start timer and end timer.
     */
    function currentMile(Data storage self)
        internal
        view
        returns (uint64, uint64)
    {
        return (self.startTime, self.endTime);
    }

    /**
     * @dev Returns the current start timer.
     */

    function currentStartMile(Data storage self)
        internal
        view
        returns (uint64)
    {
        return (self.startTime);
    }

    /**
     * @dev Returns the current end timer.
     */
    function currentEndtMile(Data storage self) internal view returns (uint64) {
        return (self.endTime);
    }

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
        require(isMileStarted(self) == true, "No_Start");
        // uint24 extendTimeSequence= self.extendTimeSequence * 1 days
        return self.endTime - 15 days <= block.timestamp;
    }
}