pragma solidity >=0.5.13 < 0.7.3;

contract LULotterySystem{

    /*
    Build a smart contract for Lottery system. 
    Participants should transfer minimum 1 ether to participate in Lottery
    Particpants can only participate once in a particular Lottery session.
    Owner can pause/reactivate the Lottery
    Owner can reset the Lottery at any stage and collect all the ethers
    Owner can transfer all the collected ethers to the Lottery winner(random winner selected by system)
    owner can destroy the smart contract
    */
    
    address owner;
    
    mapping(address => uint) public addressOfLotteryParticipants;
    address[] addressOfParticipant;
    
    uint LotteryStatus = 0;
    
    constructor() public {
        owner = msg.sender;
    }
    
    // function to Reset the Lottery
    function resetLottery() public payable onlyOwner {
        
        uint arrayLength = addressOfParticipant.length;
		
        // delete the address of the participants from the array
        for (uint i= arrayLength -1; i > 0 ; i--) {
            delete addressOfLotteryParticipants[addressOfParticipant[i]];
        }
        delete addressOfLotteryParticipants[addressOfParticipant[0]];
        
        
    }
    
    // pay ether to participate in the Lottery. Only one entry per address
    function receiveEtherForParticipation() payable public {
        require(msg.value >= 1 ether,"You require minimum 1 ether to participate in Lottery");
        require(contains(msg.sender) == 0,"You are already part of the Lottery");
        require(LotteryStatus == 0, "Lottery is Temporarly Paused");
        addressOfLotteryParticipants[msg.sender] = msg.value;
        addressOfParticipant.push(msg.sender);
    }
    
    // generate random number based on the number of participants
    function randomNumberFunction() private onlyOwner returns(uint){
        uint randomNumber = uint(keccak256(abi.encodePacked(block.difficulty,  
        block.timestamp, msg.sender, addressOfParticipant))) % addressOfParticipant.length ; 
        return(randomNumber);
        
    }
    
    // Transfer all the collected ethers to the winner
    function transferEtherToWinner() public onlyOwner{
        require(LotteryStatus == 0, "Lottery is Temporarly Paused");
        uint randomWinner = randomNumberFunction();
        address payable winner = payable(addressOfParticipant[randomWinner]);
        winner.transfer(address(this).balance);
        
    }
    
    function contains(address _addr) private returns(uint){
        return addressOfLotteryParticipants[_addr];
    }
    
    // modifier utility
    modifier onlyOwner(){
        require(msg.sender == owner, "Owner only have access to this");
        _;
    }
    
    // pause Lottery
    function pause() public onlyOwner{
        LotteryStatus = 1;
    }
    
    // Re-Activate Lottery
    function reActivate() public onlyOwner{
        LotteryStatus = 0;
    }
    
    // Contract destructor
    function destroy() public onlyOwner{
	    selfdestruct(msg.sender);
}
}