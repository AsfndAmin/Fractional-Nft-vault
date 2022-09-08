const FractionalNftVault = artifacts.require("FractionalNftVault");

module.exports = function (deployer) {
  liquidityWallet = "0xaC8901a209c63eD86B03A4DE17dE67CF8575b20B";
  holdoutPeriod = 30 * 60 * 60 * 24;
  deployer.deploy(FractionalNftVault, "50", liquidityWallet, holdoutPeriod);
};
