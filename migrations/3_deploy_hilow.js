const HiLow = artifacts.require("HiLow");
const CSCHIPToken = artifacts.require("CSCHIPToken");

module.exports = function (deployer) {
  deployer.deploy(HiLow, CSCHIPToken.address, false);
};
