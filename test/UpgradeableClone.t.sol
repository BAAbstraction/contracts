// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "deploy-yul/YulDeployer.sol";
import {stdStorage, StdStorage} from "forge-std/Test.sol";              
import { console } from "forge-std/console.sol";


contract Returns5 {
  function getNumber() external returns (uint256) {
    return 5;
  }
}

contract UpgradeableCloneTest is Test {
  YulDeployer yulDeployer;
  using stdStorage for StdStorage;

  function setUp() external {
    yulDeployer = new YulDeployer();
  }

  function testProxy() external {
    Returns5 returns5 = new Returns5();
    console.log("Impl", address(returns5));
    address proxy = yulDeployer.deployContract("UpgradeableClone");
    console.log("Proxy", proxy);
    proxy.call(abi.encode(returns5));
    Returns5 proxied = Returns5(proxy);
    assertEq(5, proxied.getNumber());
    proxy.call(abi.encode(returns5));
  }
}