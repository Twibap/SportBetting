/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a 
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() { 
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>') 
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */

module.exports = {
	// See <http://truffleframework.com/docs/advanced/configuration>
	// to customize your Truffle configuration!
	networks:{
		// ganachi-cli 사용할 때
		// ganachi-cli -p 9545
		development: {
			host: "localhost",
			port: 9545,
			network_id: "*"
		},
		// ropsten testnet에 배포할 때
		// geth --testnet --rpc --syncmode "light" console --keystore /Users/...
		ropsten:{   // truffle migrate --network ropsten
			host: "localhost",
			port: 8545,
			network_id: "*",
			gas: 2100000,
			from: "0x1773Ee2fF5Bb68962AE57086F949b60A4353CE9b"  // 네트워크 배포 시 수수료 차감 계좌
		}
	}

};
