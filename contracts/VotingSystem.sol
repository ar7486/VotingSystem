// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract VotingSystem {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public hasVoted;
    uint public candidatesCount;
    uint public votingEndTime;
    address public owner;

    event VoteCast(address indexed voter, uint candidateId);
    event VotingEnded(uint winnerId, string winnerName, uint voteCount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier hasNotVoted() {
        require(!hasVoted[msg.sender], "You have already voted");
        _;
    }

    modifier votingOpen() {
        require(block.timestamp < votingEndTime, "Voting has ended");
        _;
    }

    modifier votingClosed() {
        require(block.timestamp >= votingEndTime, "Voting is still open");
        _;
    }

    constructor(uint _durationMinutes) {
        owner = msg.sender;
        votingEndTime = block.timestamp + (_durationMinutes * 1 minutes);
    }

    function addCandidate(string memory _name) public onlyOwner {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    function vote(uint _candidateId) public hasNotVoted votingOpen {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");
        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        emit VoteCast(msg.sender, _candidateId);
    }

    function endVoting() public onlyOwner votingClosed {
        uint winningVoteCount = 0;
        uint winnerId;
        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winnerId = i;
            }
        }
        emit VotingEnded(winnerId, candidates[winnerId].name, winningVoteCount);
    }
}
