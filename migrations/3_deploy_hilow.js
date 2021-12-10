const HiLow = artifacts.require("HiLow");

module.exports = function (deployer) {
  deployer.deploy(HiLow);
};
