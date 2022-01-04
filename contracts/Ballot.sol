// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract Ballot {
    struct Voter {
        uint256 weight; // weight is accumulated by delegation
        bool voted; // if true, that person already voted
        address delegate; // person delegated to
        uint256 vote; // index of the voted proposal
    }

    struct Coordinates {
        uint256 x1;
        uint256 x2;
        uint256 y1;
        uint256 y2;
    }

    // This is a type for a single proposal.
    struct Proposal {
        bytes32 name; // short name (up to 32 bytes)
        Coordinates coo;
        bool isGetLands;
        address to;
        uint256 voteCount; // number of accumulated votes
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
        uint256 x1_,
        uint256 x2_,
        uint256 y1_,
        uint256 y2_,
        bool isGetLands_,
        address to_
    ) {
        // set the proposals to current owners
        chairperson = msg.sender;

        //set the voters address
        for (uint256 i = 0; i < _voters.length; i++) {
            voters[_voters[i]].weight = 1;
        }

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

    // Give `voter` the right to vote on this ballot.
    // May only be called by `chairperson`.
    function giveRightToVote(address voter) external {
        require(msg.sender == chairperson, "Only chairperson can give right to vote.");
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0, "The voter does not have vote rights");
        voters[voter].weight = 1;
    }

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(uint256 proposal) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() public view returns (uint256 winningProposal_) {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < proposals.length; p++) {
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
}
