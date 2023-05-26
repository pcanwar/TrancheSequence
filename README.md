---
title: Tranche Sequence
description: A tranche sequence refers to a series of payment opportunities that occur at specified time intervals.

author: Anwar Alruwaili @pcanwar <ipcanw@gmail.com>, Dov Kruger, Shaun Cole @secole1
discussions-to: <URL>
status: Draft
type: Standards Track
category: ERC # Only required for Standards Track. Otherwise, remove this field.
created: 2019
# requires: <EIP number(s)> # Only required when you reference an EIP in the `Specification` section. Otherwise, remove this field.
---

## Abstract:

This concept is extended through a library that builds on ERC20, ERC721, and other protocols, offering a transparent and structured approach to on-chain time management. With the help of additional functions, the library enables stakeholders to define time milestones and a sequence of opportunities to evaluate and decide on the next steps.

## Motivation:

The motivation behind this library is to overcome the challenges of managing multi-stage projects or use cases on utility tokens or NFTs while providing a fair and transparent approach to on-chain time management. This structured approach facilitates effective smart contract management and enables stakeholders to progress and make informed decisions. The library can be applied to various use cases, such as salary negotiations, project funding, or resource allocation, promoting trust and collaboration among stakeholders. The protocol's flexibility and transparency can result in a fairer and more effective decision-making process for all parties involved.

The following properties make tranche sequences an effective tool for managing multi-stage use cases and projects on utility tokens or NFTs in a structured and transparent manner:

### Features

- It is useful library to contain multiple hierarchies timestamp.
- It adds a list of the timestamp.
- Increase sequence based on the exsiting sequence in the contract.
- Time can be increased on time if it is needed in the smart contract
- Admin can only increased the time
- There is a rest time on sequence to provide flexibility for stakeholders.
- There is no decresed time function, meaning once a timestamp is added, it cannot be removed or modified

### Tech

- InitMileStone function should be run in the smart contract constructor and also after reset the milestone

## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 and RFC 8174.

## Test Cases

```sh
    constructor(
        uint64 newTranchePeriod,
        uint64 newExtendSequence,
        TrancheSequence.TimeUnit UTNewTranchePeriod,
        TrancheSequence.TimeUnit UTnewExtendSequence
    ) {
        trancheData.initMileStone(
            newTranchePeriod,
            UTNewTranchePeriod,
            newExtendSequence,
            UTnewExtendSequence
        );
    }
```

- Increase MileStone based on the exsiting MileStone in the contract.

```sh
    function initMileStone(
        Data storage self, // Initialization storage ones
        uint64 newTranchePeriod,
        TimeUnit trancheTimeUnit,
        uint64 newExtendSequence,
        TimeUnit extendTimeUnit
    ) internal {
        // require(!ones.isStarted);
        // require(self.tranche > 0 && self.startTime <= block.timestamp);

        uint64 currentTime = uint64(block.timestamp);
        updateTranchePeriod(self, newTranchePeriod, trancheTimeUnit);
        updateExtendSequence(self, newExtendSequence, extendTimeUnit);
        // ones.isStarted = true;
        self.startTime = currentTime;
        self.endTime = currentTime + self.tranche;
        // self.tranche = self.tranche;
    }
```

- Pass the missing time at the end of the MileStone if there was no extended
  - it works only if there is no extanded occur or missing to increase the milestone..

```sh


```

## Rationale

Backwards Compatibility
No backward compatibility issues found.

The composable extension is OPTIONAL for this library.

## License

MIT
