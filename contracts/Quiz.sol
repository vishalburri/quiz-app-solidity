pragma solidity ^0.4.23;

contract Quiz {
  
  address public owner;
  uint public numPlayers;
  uint public totPlayers;
  uint public quizFee;
  uint endJoinTime;
  uint endQuiztime;
  string public question1;
  string public question2;
  string public question3;
  string public question4;
  uint[4] public answers;
  
  struct Player{
    address account;
    uint[4] choice;
    uint prize;
    uint timestamp;
  }
  
  mapping (address => uint) pendingAmount;
  mapping (uint => Player) Players;
  mapping (address => uint) playerIndex;
  
  constructor(uint _n,uint _jointime,uint _quiztime,uint _fee) public {
      owner = msg.sender;
      totPlayers = _n;
      quizFee = _fee;
      endJoinTime = now + _jointime;
      endQuiztime = endJoinTime + _quiztime;
      question1 = "1+1 ?";
      question2 = "2+2 ?";
      question3 = "3+3 ?";
      question4 = "4+4 ?";
      answers[0] = 1;
      answers[1] = 2;
      answers[2] = 3;
      answers[3] = 4;
  }
  
  modifier onlyOwner() {
    require(msg.sender == owner,"Only owner is allowed to call this method"); _;
  }

  function joinQuiz() public payable {
    require(numPlayers < totPlayers,"Player limit exceeded");
    require(msg.value >= quizFee,"Insufficient fee");
    require (now < endJoinTime,"Time up for joining quiz");
    numPlayers++;
    playerIndex[msg.sender] = numPlayers;
    Players[numPlayers].account = msg.sender;
    pendingAmount[msg.sender] = msg.value - quizFee;
  }
  //think of ques to ques deadline(diif to implement) or whole deadline and process by timestamps of answers
  //think of hashing ques and answers for privacy of ques and ans(dont know exactly)
  function startQuiz () public constant returns(string,string,string,string){
    //require (now > endJoinTime && now < endQuiztime,"Cannot start now");
    return (question1,question2,question3,question4);  
  }
  
  function endQuiz (uint[4] _sol) public {

    //require (now > endJoinTime && now < endQuiztime,"Time up");
    for(uint i=0;i<4;i++)
        Players[playerIndex[msg.sender]].choice[i] = _sol[i];
    Players[playerIndex[msg.sender]].timestamp = now;    
  }
  
  function getWinners() public onlyOwner{
    //require (now > endQuiztime);
    uint winner = 0;
    uint i;
    for( i=0;i<4;i++){
        uint prev = 2**100 - 1;
        for(uint j=1;j<=numPlayers;j++){
            if(Players[j].choice[i]==answers[i] && Players[j].timestamp < prev){
              prev = Players[j].timestamp;
              winner = j;
            }
        }
         if(winner > 0){
         uint prize = (3*quizFee*numPlayers)/16;
         pendingAmount[Players[winner].account] += prize;
       }
    }
    //transfer remaining pending balance to them
    // for( i=1;i<=numPlayers;i++){
    //   uint amount = pendingAmount[Players[i].account];
    //   if(amount > 0){
    //     pendingAmount[Players[i].account] = 0;
    //     Players[i].account.transfer(amount);
    //   }
    // }


  }
  function withDraw () public {
      uint amount = pendingAmount[msg.sender];
      if(amount > 0){
        pendingAmount[msg.sender] = 0;
        msg.sender.transfer(amount);
      }
  }
  
  
}
