const HiLow = artifacts.require("HiLow");

module.exports = function (deployer) {
  deployer.deploy(HiLow, '0x280994780120FeD317b33fD6BBfFbD5f65545Cc8', true);
};
