const CSCHIPToken = artifacts.require("CSCHIPToken");

module.exports = function (deployer) {
  deployer.deploy(CSCHIPToken);
};
