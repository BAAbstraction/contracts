// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import { MainFactory } from "../src/MainFactory.sol";
import { console } from "forge-std/console.sol";

contract NFTOptionsDeploy is Script {
  event Bbb(bytes32);

  function run() external {
    vm.startBroadcast();
    MainFactory mainFactory = MainFactory(0xfBA25AcF53b559eA4feB3ed69F357189FCc4F421);
    bytes32 salt = bytes32(uint256(6167569445235488));
    bytes32 hash = keccak256(abi.encodePacked(salt));
    // mainFactory.commit(hash);
    // mainFactory.mint(salt);

    mainFactory.deploy(
      337136894563375204375215313624744436759404588043,
      abi.encodePacked(uint184(0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000), uint160(0xdA0741E313711FE2586A4Ffe6e52E27D08826b09), uint120(0x5af43d82803e903d91602b57fd5bf3))
    );

    vm.stopBroadcast();
  }
}

// futureAddress 0x0000004516981024d40e7e3D85bC9C40bF92038B
// salt 1631637135927079

// token id 320240688765804000256717929274618424152124892904
