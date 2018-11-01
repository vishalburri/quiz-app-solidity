pragma solidity ^0.4.23;

contract Quiz {
  
  address public owner;
  uint public numPlayers;
  uint public totPlayers;
  uint public quizFee;
  uint endJoinTime;
  uint endQuiztime;
  string question1;
  string question2;
  string question3;
  string question4;
  bytes32[4] answers;
  bytes32 secret;
  
  struct Player{
    address account;
    uint[4] choice;
    uint timestamp;
  }
  
  mapping (address => uint) pendingAmount;
  mapping (uint => Player) Players;
  mapping (address => uint) playerIndex;
  mapping (address => bool) public isValid;
  
  event Collected(address sender,uint amount);
  
  constructor(uint _n,uint _jointime,uint _quiztime,uint _fee,bytes32 _secret,uint[4] _key) public {
      
      require (_fee > 0 && _n>0 && _jointime >0 && _quiztime >0,"invalid inputs to deploy");
      
      owner = msg.sender;
      totPlayers = _n;
      quizFee = _fee;
      secret = _secret;
      endJoinTime = now + _jointime;
      endQuiztime = endJoinTime + _quiztime;
      //can send questions as arguments
      question1 = "What is a blockchain?";
      question2 = "What is UTXO?";
      question3 = "Who created Bitcoin?";
      question4 = "What does P2P stand for?";
      answers[0] = keccak256(abi.encodePacked(_key[0],secret));
      answers[1] = keccak256(abi.encodePacked(_key[1],secret));
      answers[2] = keccak256(abi.encodePacked(_key[2],secret));
      answers[3] = keccak256(abi.encodePacked(_key[3],secret));
  }
  
  modifier onlyOwner() {
    require(msg.sender == owner,"Only owner is allowed to call this method"); _;
  }

  function joinQuiz() public payable {
    require(numPlayers < totPlayers,"Player limit exceeded");
    require(msg.value >= quizFee,"Insufficient fee");
    require (isValid[msg.sender]==false,"Invalid address");
    require (now < endJoinTime,"Time up for joining quiz");

    numPlayers++;
    playerIndex[msg.sender] = numPlayers;
    isValid[msg.sender]=true;
    Players[numPlayers].account = msg.sender;
    pendingAmount[msg.sender] = msg.value - quizFee;
  }

  function startQuiz () public constant returns(string,string,string,string){
    require (now > endJoinTime && now < endQuiztime,"Cannot start now");
    require (isValid[msg.sender]==true,"You cannot start quiz");
    
    return (question1,question2,question3,question4);  
  }
  
  function endQuiz (uint[4] _sol) public {

    require (now > endJoinTime ,"Cannot end now"); 
    require(now < endQuiztime,"Time up");
    require (isValid[msg.sender]==true,"Cannot submit twice");

    isValid[msg.sender]=false;
    for(uint i=0;i<4;i++)
        Players[playerIndex[msg.sender]].choice[i] = _sol[i];
    Players[playerIndex[msg.sender]].timestamp = now;    
  }
  
  function getWinners() public onlyOwner  {
    require (now > endQuiztime,'Quiz did not end ');
    //calculate winner for each ques based on timestamp and add prize
    uint winner = 0;
    uint i;
    for( i=0;i<4;i++){
        uint prev = 2**256 - 1;
        for(uint j=1;j<=numPlayers;j++){
           
            if(answers[i] == keccak256(abi.encodePacked(Players[j].choice[i],secret)) && Players[j].timestamp < prev){
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
    for( i=1;i<=numPlayers;i++){
      uint amount = pendingAmount[Players[i].account];
      emit Collected(Players[i].account,amount);
      
      if(amount > 0){
        pendingAmount[Players[i].account] = 0;
        Players[i].account.transfer(amount);
      }
    }
    // send contract balance to owner;
    selfdestruct(owner);
  }
  
  
}
