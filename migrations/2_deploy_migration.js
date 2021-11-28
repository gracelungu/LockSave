const LockSave = artifacts.require("./LockSave.sol");

module.exports = function(deployer) {
  deployer.deploy(LockSave);
};