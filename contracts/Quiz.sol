pragma solidity ^0.4.23;

contract Quiz {
  
  address public owner;
  uint public numPlayers;
  uint public totPlayers;
  uint public quizFee;
  uint endJoinTime;
  uint endRevealTime;
  uint endQuiztime;
  string question1;
  string question2;
  string question3;
  string question4;
  bytes32[4] answers;
  bytes32 secret;
  bool isReveal;
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
  
  constructor(uint _n,uint _jointime,uint _revealtime,uint _quiztime,uint _fee,bytes32 _secret) public {
      
      require (_fee > 0 && _n>0 && _jointime >0 && _quiztime >0 && _revealtime >0 ,"invalid inputs to deploy");
      
      owner = msg.sender;
      totPlayers = _n;
      quizFee = _fee;
      secret = _secret;
      endJoinTime = now + _jointime;
      endRevealTime = endJoinTime + _revealtime;
      endQuiztime = endRevealTime + _quiztime;
  }
  
  modifier onlyOwner() {
    require(msg.sender == owner,"Only owner is allowed to call this method"); _;
  }

  function joinQuiz() public payable {
    require(numPlayers < totPlayers,"Player limit exceeded");
    require(msg.value >= quizFee,"Insufficient fee");
    require (isValid[msg.sender]==false,"Invalid address");
    require (now < endJoinTime,"Time up for joining quiz");
    require (msg.sender!=owner,"owner cannot join quiz");
    

    numPlayers++;
    playerIndex[msg.sender] = numPlayers;
    isValid[msg.sender]=true;
    Players[numPlayers].account = msg.sender;
    pendingAmount[msg.sender] = msg.value - quizFee;
  }
  
  function revealQuestions(uint[4] _key) public onlyOwner{

      require (now > endJoinTime && now < endRevealTime,"Cannot reveal now");
      isReveal = true;  
      //can send this as arguments
      question1 = "What is a blockchain?";
      question2 = "What is UTXO?";
      question3 = "Who created Bitcoin?";
      question4 = "What does P2P stand for?";
      for(uint i=0;i<4;i++)
        answers[i] = keccak256(abi.encodePacked(_key[i],secret));
  }

  function startQuiz () public constant returns(string,string,string,string){
    require (now > endRevealTime && now < endQuiztime,"Cannot start now");
    require (isValid[msg.sender]==true,"You cannot start quiz");
    require (isReveal,"Questions not Revealed by owner please withdraw your amount");
    
    return (question1,question2,question3,question4);  
  }

  function withdraw () public {
    
    require (now > endRevealTime,"Cannot withdraw now");
    require (isReveal==false,"Questions are Revealed you cant withdraw");
    require (isValid[msg.sender],"You cant withdraw");
      
    isValid[msg.sender]=false;
    uint amount = pendingAmount[msg.sender];
    pendingAmount[msg.sender] = 0;
    emit Collected(msg.sender,quizFee+amount);
    msg.sender.transfer(quizFee+amount);
  }
  
  
  function endQuiz (uint[4] _sol) public {

    require (now > endRevealTime ,"Cannot end now"); 
    require(now < endQuiztime,"Time up");
    require (isValid[msg.sender]==true,"Cannot submit twice");
    require (isReveal,"Questions not Revealed");
    
    isValid[msg.sender]=false;
    for(uint i=0;i<4;i++)
        Players[playerIndex[msg.sender]].choice[i] = _sol[i];
    Players[playerIndex[msg.sender]].timestamp = now;    
  }
  
  function getWinners() public onlyOwner  {
    require (now > endQuiztime,'Quiz did not end ');
    require (isReveal,"You didnt reveal Questions");
    
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
