// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import { MainFactory } from "../src/MainFactory.sol";
import { IntermediateFactory } from "../src/IntermediateFactory.sol";
import { TransparentUpgradeableProxy, ITransparentUpgradeableProxy } from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { console } from "forge-std/console.sol";

contract NFTOptionsDeploy is Script {
  function run() external {
    vm.startBroadcast();
    // 1) deploy IF-Implementation
    IntermediateFactory intermediateFactory = new IntermediateFactory();
    // 2) deploy MF-Implementation
    MainFactory mainFactory = new MainFactory();

    // 3) deploy IF-Proxy 0xdA0741E313711FE2586A4Ffe6e52E27D08826b09
    new TransparentUpgradeableProxy(
      address(intermediateFactory),
      msg.sender,
      abi.encodeWithSelector(IntermediateFactory.initialize.selector)
    );
    // 4) deploy MF-Proxy 0xfBA25AcF53b559eA4feB3ed69F357189FCc4F421
    new TransparentUpgradeableProxy(
      address(mainFactory),
      msg.sender,
      abi.encodeWithSelector(MainFactory.initialize.selector, intermediateFactory)
    );
    vm.stopBroadcast();
  }
}