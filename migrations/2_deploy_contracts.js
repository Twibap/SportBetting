var Wager = artifacts.require("./Wager.sol");

module.exports = function(deployer) {
	const fee_rate = 100;
	const fee_denominator = 1000;
	deployer.deploy(Wager, fee_rate, fee_denominator);
};
