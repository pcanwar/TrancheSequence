# Tranche Sequence

A tranche sequence refers to a series of payment opportunities that occur at specified time intervals.

## Abstract:

This concept is extended through a library that builds on ERC20, ERC721, and other protocols, offering a transparent and structured approach to on-chain time management. With the help of additional functions, the library enables stakeholders to define time milestones and a sequence of opportunities to evaluate and decide on the next steps.

## Motivation:

The motivation behind this library is to overcome the challenges of managing multi-stage projects or use cases on utility tokens or NFTs while providing a fair and transparent approach to on-chain time management. This structured approach facilitates effective smart contract management and enables stakeholders to progress and make informed decisions. The library can be applied to various use cases, such as salary negotiations, project funding, or resource allocation, promoting trust and collaboration among stakeholders. The protocol's flexibility and transparency can result in a fairer and more effective decision-making process for all parties involved.

The following properties make tranche sequences an effective tool for managing multi-stage use cases and projects on utility tokens or NFTs in a structured and transparent manner:

## Features
- It is useful library to contain multiple hierarchies timestamp. 
- It adds a list of the timestamp.
- Increase sequence based on the exsiting sequence in the contract.
- Time can be increased on time if it is needed in the smart contract
- Admin can only increased the time
- There is a rest time on sequence to provide flexibility for stakeholders.
- There is no decresed time function, meaning once a timestamp is added, it cannot be removed or modified

## Tech
- InitMileStone function should be run in the smart contract constructor and also after reset the milestone


## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 and RFC 8174.


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

## Rationale


Backwards Compatibility
No backward compatibility issues found.

Test Cases


The composable extension is OPTIONAL for this library.

## License
MIT
**Free Software, Hell Yeah!**
