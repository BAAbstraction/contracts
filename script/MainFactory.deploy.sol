// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import { MainFactory } from "../src/MainFactory.sol";
import { IntermediateFactory } from "../src/IntermediateFactory.sol";
import { TransparentUpgradeableProxy, ITransparentUpgradeableProxy } from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { console } from "forge-std/console.sol";

/**
 * Deploy to anvil:
 * forge script NFTOptionsDeploy --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvv
 * IF Proxy: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
 * MF Proxy: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
 */
contract NFTOptionsDeploy is Script {
  function run() external {
    vm.startBroadcast();
    // 1) deploy IF-Implementation
    IntermediateFactory intermediateFactory = new IntermediateFactory();
    // 2) deploy MF-Implementation
    MainFactory mainFactory = new MainFactory();

    // 3) deploy IF-Proxy 0xdA0741E313711FE2586A4Ffe6e52E27D08826b09
    TransparentUpgradeableProxy IFProxy = new TransparentUpgradeableProxy(
      address(intermediateFactory),
      msg.sender,
      abi.encodeWithSelector(IntermediateFactory.initialize.selector)
    );
    // 4) deploy MF-Proxy 0xfBA25AcF53b559eA4feB3ed69F357189FCc4F421
    TransparentUpgradeableProxy MFProxy = new TransparentUpgradeableProxy(
      address(mainFactory),
      msg.sender,
      abi.encodeWithSelector(MainFactory.initialize.selector, IFProxy)
    );
    vm.stopBroadcast();
    console.log("IF Proxy: %s", address(IFProxy));
    console.log("MF Proxy: %s", address(MFProxy));
  }
}