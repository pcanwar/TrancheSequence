# CapSequence


# CapSequence, MileSequence

CapSequence is a sequence of opportunities for making payment eg.(rewards). It gets started  every period of time.
 
## Features
- It is useful library to contain multiple hierarchies timestamp. 
- It adds a list of the time.
- Increase CapSequence based on the exsiting CapSequence in the contract.
- Time can be increased/ controled  by admin if it is needed in the smart contract

## Tech
- InitMileStone function should be run in the smart contract constructor and also after reset the milestone

```sh
    function initMileStone(Data storage self)
    internal
    {
        require(self.period > 0 && self.startTime < block.timestamp);
        uint64 currentTime = uint64(block.timestamp);
        uint64 reTimer ;
        uint64 period = self.period;
        self.startTime = currentTime + reTimer;
        self.endTime = ((30 days  * self.period) + currentTime) ;
        reTimer = (30 days * period) ;

    }
```
- Increase MileStone based on the exsiting MileStone in the contract.
```sh
    function increaseMileStone(Data storage self) 
    internal
         {
        require(isExtandable(self), "Not_Extandable");
        uint64 currentTime = self.endTime;
        uint64 reTimer ;
        self.startTime = currentTime + reTimer;
        self.endTime = ((30 days * self.period) + currentTime + passTimer(self)) ;
        reTimer = (30 days  * self.period) ;
    }
```

- Pass the missing time at the end of the MileStone if there was no extended  
     * it works only if there is no extanded occur or missing to increase the milestone..

```sh
    function passTimer(Data storage self) 
    view private returns(uint64) {
        uint64 timestamp = uint64(block.timestamp);
        if (self.endTime < timestamp){
            uint64 _b = timestamp - self.endTime;
            return _b;
        }else{
            return 0;
        }
    }
    
```


## License
MIT
**Free Software, Hell Yeah!**
