1.Install dependencies :
  npm i
2.Compile
  truffle compile
3.Start truffle develop network
  truffle develop
4.Migrate code on local blockchain
  migrate --reset
5.Test the code
  test



Online Quiz App
Your assignment if you choose to attempt is to make a quiz app where up to ​ N
number of people can participate in a single game of 4 questions.
Rules of the game:
1. N ​ number of people participate in a single game of 4 questions.
2. Each person pays a participation fee (​ pFee ) ​ before entering the game.
3. Let ​ tFee ​ denote the aggregated some of all the participants’ fee in the game.
4. For each correct answer a participant gets 3/16*​ tFee ​ reward. That is, the
contract earns a quarter of ​ tFee ​ in each game.
Apart from these basic rules, students are free to end more sophistication as long as
it remains a fair and justifiable game.
Also, based on what you studied so far, figure out all the security measures required
to implement such a system. It's a very simple problem, but you are expected to
come with your own complex versions. The more unique and complex system you
build, the higher marks you get.
Please don't ask and discuss the security measures and new sophistications on
moodle, it's a part of the assignment to get to the details and think of various
aspects, you are suppose to get them on your own as you develop the system.
Testing
You are also required to design and write test cases in truffle for the contract.
The test cases must be exhaustive i.e., all possible cases, including the boundary
cases, must be covered
Scoring
The scoring will be based on the following:
1. Security, privacy and cost efficiency of smart contracts.
2. Uniqueness and added sophistication.
3. Test cases covered.
Other Details
● Programming Language : Solidity
● Testing Platform : Truffle
● Assignment Deadline : 31 October, 8:29 AM
