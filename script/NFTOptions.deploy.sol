// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import { NFTOptions } from "../src/NFTOptions.sol";

contract NFTOptionsDeploy is Script {
  function run() external {
    vm.startBroadcast();
    new NFTOptions("https://meta.address-option.com/");
  }
}