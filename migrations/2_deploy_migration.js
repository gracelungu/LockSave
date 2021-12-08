const LockSave = artifacts.require("./LockSave.sol");

module.exports = (deployer, network, accounts) => {
  const [admin] = accounts;
  if (network === "development") {
    deployer.deploy(LockSave, admin);
  }

  if (network === "bsc") {
    deployer.deploy(LockSave, admin);
  }
};
