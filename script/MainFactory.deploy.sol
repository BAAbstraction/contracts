// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import { MainFactory } from "../src/MainFactory.sol";
import { TransparentUpgradeableProxy } from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { console } from "forge-std/console.sol";

contract NFTOptionsDeploy is Script {
  function run() external {
    vm.startBroadcast();
    MainFactory logic = new MainFactory("https://meta.address-option.com/", new uint256[](0), new uint256[](0));
    console.log("MainFactory deployed at", address(logic));
    new TransparentUpgradeableProxy(address(logic), 0xd4d61C2bbefe9278E78CD5f7ae893101eb777eE9, "");
  }
}