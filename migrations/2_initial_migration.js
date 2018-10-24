var Quiz = artifacts.require("./Quiz.sol");

module.exports = function(deployer) {
  deployer.deploy(Quiz,5,10,20);
};
