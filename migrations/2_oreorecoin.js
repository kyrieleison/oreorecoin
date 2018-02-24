var OreOreCoin = artifacts.require("./OreOreCoin.sol");

module.exports = function(deployer) {
  var supply = 10000;
  var name = 'OreOreCoin';
  var symbol = 'oc';
  var decimals = 0;
  deployer.deploy(OreOreCoin, supply, name, symbol, decimals);
};
