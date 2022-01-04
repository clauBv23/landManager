require('@nomiclabs/hardhat-ethers');
require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-web3');
require('@nomiclabs/hardhat-truffle5');
require('hardhat-deploy');

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  namedAccounts: {
    deployer: 0,
    user1: 1,
    user2: 2,
  },
  solidity: '0.8.11',
};
