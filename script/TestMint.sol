// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import { MainFactory } from "../src/MainFactory.sol";
import { console } from "forge-std/console.sol";
import { console2 } from "forge-std/console2.sol";

/**
 * for anvil we use second address:
 * 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;0x70997970C51812dc3A010C7d01b50e0d17dc79C8
 * forge script TestMint --rpc-url http://127.0.0.1:8545 --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d --broadcast -vvv

 * IF-clone: 0x55f9105D3096c46Ecf7Fc30fB590697a0003155f
 * Deployed contract: 0x9dE43760484Ed75C3232218a58d4136d1C8338FC
 */

contract TestMint is Script {
  function run() external {
    vm.startBroadcast();
    MainFactory mainFactory = MainFactory(0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9); // in anvil
    bytes32 salt = bytes32(uint256(958135318113));
    uint256 randomFactor = 31337;
    bytes32 hash = keccak256(abi.encodePacked(salt, randomFactor));
    mainFactory.commit(hash);
    uint256 tokenId = mainFactory.reveal(salt, randomFactor);

    // yul: Runtime{ mstore(0x0, 0x5555555555555555555) return(0x0, 0x20) }
    bytes memory contractToDeploy = abi.encodePacked(uint256(0x6013600d60003960136000f3fe690555555555555555555560005260206000f3));
    mainFactory.deploy(
      tokenId,
      contractToDeploy
    );

    vm.stopBroadcast();

    // test deployed contract
    address deployed = 0xbBbbBCbBC760C63Aa717FA3BA8Bfaf445B05B3E8;
    console2.logBytes(deployed.code);
    (bool success, bytes memory returnal) = deployed.call("test");
    console2.logBytes(returnal);
  }
}

// futureAddress 0x0000004516981024d40e7e3D85bC9C40bF92038B
// salt 1631637135927079

// token id 320240688765804000256717929274618424152124892904
