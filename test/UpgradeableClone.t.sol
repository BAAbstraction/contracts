// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "deploy-yul/YulDeployer.sol";
import {stdStorage, StdStorage} from "forge-std/Test.sol";              
import { console } from "forge-std/console.sol";


contract Returns5 {
  function getNumber() external pure returns (uint256) {
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
    (bool success, ) = proxy.call(abi.encode(returns5));
    assertEq(success, true);
    Returns5 proxied = Returns5(proxy);
    assertEq(5, proxied.getNumber());
    (bool success2, ) = proxy.call(abi.encode(returns5));
    assertEq(success2, false);
  }
}