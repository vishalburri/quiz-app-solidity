pragma solidity ^0.4.23;

contract Quiz {
  
  address public owner;
  uint public numPlayers;
  uint public totPlayers;
  uint public quizFee;
  uint endJoinTime;
  uint endQuiztime;
  string[4] questions;
  uint[4] answers;
  
  struct Player{
    address account;
    uint[4] choice;
    uint prize;
    uint timestamp;
  }
  
  mapping (address => uint) pendingAmount;
  mapping (uint => Player) Players;
  mapping (address => uint) playerIndex;
  
  constructor(uint _n,uint _jointime,uint _quiztime) public {
      owner = msg.sender;
      totPlayers = _n;
      endJoinTime = now + _jointime;
      endQuiztime = endJoinTime + _quiztime;
      questions[0] = "1+1 ?";
      questions[1] = "2+2 ?";
      questions[2] = "3+3 ?";
      questions[3] = "4+4 ?";
      answers[0] = 1;
      answers[1] = 2;
      answers[2] = 3;
      answers[3] = 4;
  }
  
  modifier onlyOwner() {
    require(msg.sender == owner,"Only owner is allowed to call this method"); _;
  }

  function joinQuiz() public payable {
    require(totPlayers <= numPlayers,"Player limit exceeded");
    require(msg.value >= quizFee,"Insufficient fee");
    require (now < endJoinTime,"Time up for joining quiz");
    numPlayers++;
    playerIndex[msg.sender] = numPlayers;
    Players[numPlayers].account = msg.sender;
    pendingAmount[msg.sender] = msg.value - quizFee;
  }
  //think of ques to ques deadline(diif to implement) or whole deadline and process by timestamps of answers
  //think of hashing ques and answers for privacy of ques and ans(dont know exactly)

  function startQuiz (uint[4] _sol) public {
    require (now > endJoinTime && now < endQuiztime,"Time up");
    for(uint i=0;i<4;i++)
        Players[playerIndex[msg.sender]].choice[i] = _sol[i];
    Players[playerIndex[msg.sender]].timestamp = now;    
  }
  
  function getWinners() public onlyOwner{
    require (now > endQuiztime);
    uint prev = ~uint256(0);
    uint winner = 0;
    
    for(uint i=0;i<4;i++){
        for(uint j=1;j<=numPlayers;j++){
            if(Players[j].choice[i]==answers[i] && Players[j].timestamp < prev){
              prev = Players[j].timestamp;
              winner = j;
            }
        }
        uint prize = (3*quizFee*numPlayers)/16;
        pendingAmount[Players[winner].account] += prize;
    }
    // transfer remaining pending balance to them
    for( i=1;i<=numPlayers;i++){
      uint amount = pendingAmount[Players[i].account];
      if(amount > 0){
        pendingAmount[Players[i].account] = 0;
        Players[i].account.transfer(amount);
      }
    }


  }
  
}
