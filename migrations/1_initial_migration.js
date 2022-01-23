const Migrations = artifacts.require("GFTShoppe");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
