// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./LandManager.sol";

contract Ballot {
    address public landManagerContractAddr;

    struct Voter {
        bool voted; // if true, that person already voted
        uint16 vote; // index of the voted proposal
    }

    struct Coordinates {
        uint32 x1;
        uint32 x2;
        uint32 y1;
        uint32 y2;
    }

    // This is a type for a single proposal.
    struct Proposal {
        bytes32 name; // short name (up to 32 bytes)
        Coordinates coo;
        bool isGetLands;
        address to;
        uint32 voteCount; // number of accumulated votes
    }

    address public chairperson;

    // This declares a state variable that
    // stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;

    // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;

    /// Create a new ballot to choose one of `proposals`.
    constructor(
        address[] memory _voters,
        uint32 x1_,
        uint32 x2_,
        uint32 y1_,
        uint32 y2_,
        bool isGetLands_,
        address to_
    ) {
        // set the proposals to current owners
        chairperson = _voters[0];

        landManagerContractAddr = msg.sender;

        // set the proposal
        Coordinates memory _coo;
        _coo.x1 = x1_;
        _coo.x2 = x2_;
        _coo.y1 = y1_;
        _coo.y2 = y2_;

        proposals.push(
            Proposal({
                name: "decline",
                to: to_,
                coo: _coo,
                isGetLands: isGetLands_,
                voteCount: 0
            })
        );

        proposals.push(
            Proposal({
                name: "accept",
                to: to_,
                coo: _coo,
                isGetLands: isGetLands_,
                voteCount: 0
            })
        );
    }

    /// Give your vote
    function vote(uint16 proposal) external {
        require(
            LandManager(landManagerContractAddr).isOwner(msg.sender),
            "Has no right to vote"
        );
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");

        sender.voted = true;
        sender.vote = proposal;

        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += 1;
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() public view returns (uint32 winningProposal_) {
        uint32 winningVoteCount = 0;
        for (uint32 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerCoords() external view returns (Coordinates memory coords) {
        coords = proposals[winningProposal()].coo;
    }

    function winnerTo() external view returns (address to) {
        to = proposals[winningProposal()].to;
    }

    function winnerIsGetLands() external view returns (bool isGet) {
        isGet = proposals[winningProposal()].isGetLands;
    }

    function getProposal(uint32 proposal) external view returns (Proposal memory prop) {
        prop = proposals[proposal];
    }
}
