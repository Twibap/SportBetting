const Wager = artifacts.require("Wager");

contract('Wager', function(accounts) {
	var admin;
	var bettinger_0;
	var bettinger_1;
	var bettinger_2;

	var admin_starting_balance;
	var bettinger_0_win_starting_balance;
	var bettinger_1_lose_starting_balance;
	var bettinger_2_draw_starting_balance;

	var admin_ending_balance;
	var bettinger_0_win_ending_balance;
	var bettinger_1_lose_ending_balance;
	var bettinger_2_draw_ending_balance;

	admin = web3.eth.accounts[0];
	bettinger_0 = web3.eth.accounts[1];
	bettinger_1 = web3.eth.accounts[2];
	bettinger_2 = web3.eth.accounts[3];

	// check Balance at start point
	admin_starting_balance = web3.eth.getBalance(admin);
	bettinger_0_win_starting_balance 
		= web3.eth.getBalance(bettinger_0).toNumber();
	bettinger_1_lose_starting_balance 
		= web3.eth.getBalance(bettinger_1).toNumber();
	bettinger_2_lose_starting_balance 
		= web3.eth.getBalance(bettinger_2).toNumber();

	it("Withdraw only", function(){
		var wager;

		return Wager.deployed().then(function(inst){
			wager = inst;

		}).then(function(){
			wager.withdraw(0);
		});
	});
	it("Betting test", function() {
		var wager;

		return Wager.deployed().then(function(instance) {
			wager = instance;
		}).then(function() {
			// bettinger 0 do betting to win
			wager.betting.sendTransaction(0, 
				{from: bettinger_0, value: web3.toWei(1, "ether")});
		}).then(function(){
			// bettinger 1 do betting to lose
			wager.betting.sendTransaction(1, 
				{from: bettinger_1, value: web3.toWei(1, "ether")});
		}).then(function(){
			// bettinger 2 do betting to draw
			wager.betting.sendTransaction(2, 
				{from: bettinger_2, value: web3.toWei(1, "ether")});
		});
	});
	it("Withdraw after game set", function(){
		var wager;

		return Wager.deployed().then(function(inst){
			wager = inst;
		}).then(function(){
			// sendTransaction with game result.
			// 0 is home win
			// 1 is home lose
			// 2 is draw
			wager.withdraw(0);
		}).then(function(){
			admin_ending_balance = web3.eth.getBalance(admin);
			bettinger_0_win_ending_balance 
				= web3.eth.getBalance(bettinger_0).toNumber();
			bettinger_1_lose_ending_balance 
				= web3.eth.getBalance(bettinger_1).toNumber();
			bettinger_2_lose_ending_balance 
				= web3.eth.getBalance(bettinger_2).toNumber();
		}).then(function(){
			//	assert.equal();
		});
	});
});
