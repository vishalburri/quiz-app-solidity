var Quiz = artifacts.require("./Quiz.sol");

module.exports = function(deployer) {
	// keep secret key here
  const secret = "0x285714a264559271d4d0476417a4147c560679e9221b296fa6a74041e10b9792";
  deployer.deploy(Quiz,5,60,60,60,10,secret);
};
