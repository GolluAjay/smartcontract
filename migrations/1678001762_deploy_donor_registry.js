const DonorRegistry = artifacts.require('DonorRegistry')

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(DonorRegistry);
};
