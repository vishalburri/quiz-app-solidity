var Quiz = artifacts.require("Quiz");

// Helps in asserting events
const truffleAssert = require("truffle-assertions");

contract("Quiz", accounts => {
	const owner = accounts[0];
	const secret = "0x285714a264559271d4d0476417a4147c560679e9221b296fa6a74041e10b9792";
	const key = [1,2,3,4];
	describe("constructor", () => {
		describe("Assert Contract is deployed", () => {
			it("should deploy this contract", async () => {
				const instance = await Quiz.new(5,60,60,10,secret,key, { from: owner });

				let tot = await instance.totPlayers.call();
				let fee = await instance.quizFee.call();

				assert.isNotNull(instance);
				assert.equal(tot.toNumber(), 5);
				assert.equal(fee.toNumber(), 10);

				
			});
		});
		describe("Fail case", () => {
			it("should revert on invalid from address", async () => {
				try {
					const instance = await Quiz.new(5,60,60,10,secret,key, {
						from: "lol"
					});
					assert.fail(
						"should have thrown an error in the above line"
					);
				} catch (err) {
					assert.equal(err.message, "invalid address");
				}
			});
		});
	});
	describe("Quiz Register", () => {
		let instance;

		beforeEach(async () => {
			instance = await Quiz.new(5,5,5,10,secret,key, { from: owner });
		});

		describe("Success Case", () => {
			it("1 person can successfully register", async () => {
				let result = await instance.joinQuiz({
					from: accounts[1],value : web3.toWei(10, "wei")
				});
				// truffleAssert.eventEmitted(result, "event name");
				assert.equal(
					await instance.numPlayers.call(),
					1,
					"num of players registered should be 1"
				);
			});
		});
		describe("Success Case", () => {
			it("5 members can register for quiz ", async () => {
				await instance.joinQuiz({
					from: accounts[1],value : web3.toWei(10, "wei")
				});
				await instance.joinQuiz({
					from: accounts[2],value : web3.toWei(10, "wei")
				});
				await instance.joinQuiz({
					from: accounts[3],value : web3.toWei(10, "wei")
				});
				await instance.joinQuiz({
					from: accounts[4],value : web3.toWei(10, "wei")
				});
				await instance.joinQuiz({
					from: accounts[5],value : web3.toWei(10, "wei")
				});
				assert.equal(
					await instance.numPlayers.call(),
					5,
					"There should be 5 Registered players"
				);
			});
		});
		describe("Fail Case", () => {
			it("cannot register twice from same address", async () => {
				await instance.joinQuiz({
							from: accounts[1],value : web3.toWei(10, "wei")
						});
				try {
						await instance.joinQuiz({
							from: accounts[1],value : web3.toWei(10, "wei")
						});
					} catch (err) {
					assert.equal(
						err.message,
						"VM Exception while processing transaction: revert"
					);		
				}
				assert.equal(
					await instance.numPlayers.call(),
					1,
					"There should be 1 Registered players"
				);
				
			});
		});
		describe("Fail Case", () => {
			it("Insufficient fee", async () => {
				try {
						await instance.joinQuiz({
							from: accounts[1],value : web3.toWei(7, "wei")
						});
					} catch (err) {
					assert.equal(
						err.message,
						"VM Exception while processing transaction: revert"
					);		
				}
			});
		});
		describe("Fail Case", () => {
			it("Time up for registering quiz", async () => {
				const delay = ms => new Promise(res => setTimeout(res, ms));
				await delay(6*1000);
				try {
						await instance.joinQuiz({
							from: accounts[1],value : web3.toWei(10, "wei")
						});
					} catch (err) {
					assert.equal(
						err.message,
						"VM Exception while processing transaction: revert"
					);		
				}
			});
		});
	});
	describe("Submit Quiz", () => {
		let instance;

		beforeEach(async () => {
			instance = await Quiz.new(5,5,5,10,secret,key, { from: owner });
			await instance.joinQuiz({
					from: accounts[1],value : web3.toWei(10, "wei")
				});
		});

		describe("Success Case", () => {
			it("Quiz submitted", async () => {
				const delay = ms => new Promise(res => setTimeout(res, ms));
				await delay(6*1000);
				let ques = await instance.startQuiz({from:accounts[1]});
				await instance.endQuiz([1,2,3,4],{
					from: accounts[1]
				});
				// truffleAssert.eventEmitted(result, "event name");
			});
		});	
		describe("Fail Case", () => {
			it("Time up for submitting quiz", async () => {
				const delay = ms => new Promise(res => setTimeout(res, ms));
				await delay(6*1000);
				let ques = await instance.startQuiz({from:accounts[1]});
				await delay(5*1000);
				try {
						await instance.endQuiz([1,2,3,4],{
							from: accounts[1]
						});
					} catch (err) {
					assert.equal(
						err.message,
						"VM Exception while processing transaction: revert"
					);		
				}
			});
		});
	});	
	describe("Get winners", () => {
		let instance;

		beforeEach(async () => {
			instance = await Quiz.new(5,5,5,10,secret,key, { from: owner });
			await instance.joinQuiz({
					from: accounts[1],value : web3.toWei(10, "wei")
				});
			await instance.joinQuiz({
					from: accounts[2],value : web3.toWei(10, "wei")
				});
			 const delay = ms => new Promise(res => setTimeout(res, ms));
			 await delay(6*1000);
			let ques = await instance.startQuiz({from:accounts[1]});
			 await instance.endQuiz([1,2,4,3],{
					from: accounts[1]
				});
			 await instance.endQuiz([2,1,3,4],{
					from: accounts[2]
				});
		});

		describe("Success Case", () => {
			it("winner determined from owner", async () => {
			 	
			 	const delay = ms => new Promise(res => setTimeout(res, ms));
				await delay(5*1000);

				let tx = await instance.getWinners(secret,{
					from: owner
				});
				truffleAssert.eventEmitted(tx,'Collected', (ev) => {
				    return ev.sender == accounts[1] && ev.amount == 6;
				 });
				truffleAssert.eventEmitted(tx,'Collected', (ev) => {
				    return ev.sender == accounts[2] && ev.amount == 6;
				 });
			});
		});
		describe("Fail Case", () => {
			it("owner should determine winners", async () => {
				const delay = ms => new Promise(res => setTimeout(res, ms));
				await delay(5*1000);
				try {
					await instance.getWinners(secret,{
					from: accounts[1]
					});
				} catch (err) {
					assert.equal(
						err.message,
						"VM Exception while processing transaction: revert"
					);		
				}
			});
		});	
	});	
});