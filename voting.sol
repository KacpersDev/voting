pragma solidity > 0.7.0 < 0.9.0;

contract EtherElection {
    
    mapping(address => bool) enrolled;
    mapping(address => uint) votes;
    mapping(address => bool) voted;

    uint enrollements = 0;
    uint contractBalance;

    bool running = false;
    bool received = false;
    bool withdrew = false;

    address owner;
    address winner;

    constructor() {
        owner = msg.sender;
        running = true;
    }
    
    function enroll() public payable {
        require(enrollements < 3, "Max has been reached");
        require(!enrolled[msg.sender], "You have already enrolled");
        require(msg.value == 1 ether, "You need to send exatly 1 ether");
        
        enrolled[msg.sender] = true;
        enrollements++;
    }

    function vote(address candidate) public payable {
        require(msg.value == 10000 wei, "You need to send 10,000 wei to vote");
        require(!voted[msg.sender], "You have already voted");
        require(enrolled[candidate], "Address is not candidating");
        require(running, "Vote is not running");

        contractBalance += 10000 wei;
        voted[msg.sender] = true;
        votes[candidate] += 1;

        if (votes[candidate] == 5) {
            running = false;
            winner = candidate;
        }
    }

    function getWinner() public view returns (address) {
        return winner;
    }

    function claimReward() public {
        require(winner != address(0), "Winner has not been picked yet.");
        require(msg.sender == winner, "You must be winer to perform this action");
        require(!received, "You have already received your reward");


        (bool sent,) = payable(winner).call{value: 3 ether}("");
        withdrew = true;
        require(sent, "Failed to send transactionn");
    }

    function collectFees() public {
        require(winner != address(0), "Winner has not been picked yet");
        require(withdrew, "Winner didn't withdrew any money yet.");
        require(msg.sender == owner, "You must be the owner");

        (bool sent,) = payable(owner).call{value: contractBalance}("");
        require(sent, "Transaction failed");
    }
}
