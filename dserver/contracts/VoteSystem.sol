// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract VotingSystem {
    struct Vote {
        uint id;
        address creator;
        string name;
        uint rewardAmount;
        bool ended;
        address winner;
        address[] candidates;
        mapping(address => bool) hasJoined;
        mapping(address => uint) votesReceived;
        uint voterCount;
    }

    struct CandidateInfo {
        address candidate;
        uint votesReceived;
    }


    struct VoteInfo {
        uint id;
        address creator;
        string name;
        uint rewardAmount;
        bool ended;
        address winner;
        address[] candidates;
        //CandidateInfo[] candidatesInfo;
    }

    Vote[] public votes;
    uint public voteCount;
    address public owner;

    event VoteCreated(uint id, string name, address creator);
    event Voted(uint voteId, address candidate, address voter);
    event VoteEnded(uint voteId, address winner);
    event VoteError(uint voteId, address candidate, string message);
    

    constructor() {
        owner = msg.sender;
    }

    function getContractName() public pure returns (string memory) {
        return "VotingSystem";
    }

    function createVote(string memory _name, uint _rewardAmount) public payable returns (uint) {
        //require(msg.value >= _rewardAmount, "Insufficient reward amount");

        votes.push();
        Vote storage newVote = votes[votes.length - 1];

        newVote.id = voteCount;
        newVote.creator = msg.sender;
        newVote.name = _name;
        newVote.rewardAmount = _rewardAmount;
        newVote.ended = false;
        newVote.voterCount = 0;
        
        emit VoteCreated(newVote.id, _name, msg.sender);
        voteCount++;
        payable(owner).transfer(msg.value);
        return voteCount - 1;
    }

    function joinVote(uint _voteId) public payable {
        //require(_voteId < votes.length, "Invalid vote ID");
        Vote storage currentVote = votes[_voteId];
        //require(!currentVote.ended, "Vote has already ended");
        //require(!currentVote.hasJoined[msg.sender], "You have already joined this vote");
        //require(msg.value > 0, "You must pay to join the vote");

        if (_voteId >= votes.length) {
            emit VoteError(_voteId, msg.sender, "Invalid vote ID");
            return;
        }

        if (currentVote.hasJoined[msg.sender]) {
            emit VoteError(_voteId, msg.sender, "You have already joined this vote");
            return;
        }

        if (currentVote.ended) {
            emit VoteError(_voteId, msg.sender, "Vote has already ended");
            return;
        }

        if (msg.value <= 0) {
            emit VoteError(_voteId, msg.sender, "Insufficient payment");
            return;
        }

        currentVote.candidates.push(msg.sender);
        currentVote.hasJoined[msg.sender] = true;

        if (currentVote.voterCount >= 3) {
            endVote(_voteId);
        }
    }

    function vote(uint _voteId, address _candidate) public {
        //require(_voteId < votes.length, "Invalid vote ID");
        Vote storage targetVote = votes[_voteId];
        //require(!targetVote.ended, "Vote has already ended");
        //require(targetVote.hasJoined[_candidate], "Candidate has not joined this vote");
        //require(!targetVote.hasJoined[msg.sender], "Candidates cannot vote");

        if (targetVote.hasJoined[msg.sender]) {
            emit VoteError(_voteId, msg.sender, "Candidates cannot vote");
            return;
        }

        if (targetVote.ended) {
            emit VoteError(_voteId, msg.sender, "Vote has already ended");
            return;
        }

        targetVote.votesReceived[_candidate]++;
        targetVote.voterCount++;

        if (targetVote.voterCount >= 3) {
            endVote(_voteId);
        }

        emit Voted(_voteId, _candidate, msg.sender);
    }

    function endVote(uint _voteId) public payable{
        require(_voteId < votes.length, "Invalid vote ID");
        Vote storage endingVote = votes[_voteId];
        require(!endingVote.ended, "Vote has already ended");

        uint maxVotes = 0;
        address winner;

        for (uint i = 0; i < endingVote.candidates.length; i++) {
            if (endingVote.votesReceived[endingVote.candidates[i]] > maxVotes) {
                maxVotes = endingVote.votesReceived[endingVote.candidates[i]];
                winner = endingVote.candidates[i];
            }
        }

        endingVote.ended = true;
        endingVote.winner = winner;

        if (winner != address(0)) {
            payable(winner).transfer(endingVote.rewardAmount * 1e12);
        }

        emit VoteEnded(_voteId, winner);
    }


    function getVotes() public view returns (VoteInfo[] memory) {
        VoteInfo[] memory voteInfos = new VoteInfo[](voteCount);

        for (uint i = 0; i < voteCount; i++) {
            Vote storage currentVote = votes[i];

            CandidateInfo[] memory candidatesInfo = new CandidateInfo[](currentVote.candidates.length);
            for (uint j = 0; j < currentVote.candidates.length; j++) {
                address candidate = currentVote.candidates[j];
                candidatesInfo[j] = CandidateInfo({
                    candidate: candidate,
                    votesReceived: currentVote.votesReceived[candidate]
                });
            }

            voteInfos[i] = VoteInfo({
                id: currentVote.id,
                creator: currentVote.creator,
                name: currentVote.name,
                rewardAmount: currentVote.rewardAmount,
                ended: currentVote.ended,
                winner: currentVote.winner,
                candidates: currentVote.candidates
            });
        }
        return voteInfos;
    }
}