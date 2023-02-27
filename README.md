# CapSequence


# Tranche Sequence

Tranche Sequence is a sequence of opportunities for making payment. It gets started every period of time.


## Abstract:

The following standard is extending ERC20, ERC721, and etc and allows for multi-stage schemes that aim to provide a fair and transparent approach to on-chain time management. The standard utilizes additional functions to define time milestones and a sequence of opportunities for stakeholders to evaluate and also decide on the next steps.

## Motivation:

The motivation behind this is to address the challenges of managing multi-stage use cases or projects on utility tokens or NFTs and to provide a fair and transparent approach on-chain time management. Effective smart contract management requires a structured approach that enables stakeholders to progress and decide on the next steps. The standard can be applied to various use cases, such as salary negotiations, project funding, sequence of funcding or resource allocation. The standard is designed to be promoting trust and collaboration among stakeholders. The protocol's flexibility and transparency can result in a fairer and more effective decision-making process for all parties involved.

Tranche Sequence have a bunch of different properties, and here are some ones:

## Features
- It is useful library to contain multiple hierarchies timestamp. 
- It adds a list of the time.
- Increase CapSequence based on the exsiting CapSequence in the contract.
- Time can be increased/ controled  by admin if it is needed in the smart contract

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


The composable extension is OPTIONAL for this standard.

## License
MIT
**Free Software, Hell Yeah!**
