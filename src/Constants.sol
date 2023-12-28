// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IntermediateFactory } from "./IntermediateFactory.sol";
import { ECDSAUpgradeable } from "openzeppelin/utils/cryptography/ECDSAUpgradeable.sol";

abstract contract Constants {
  event Commit(address indexed who, bytes32 hash);
  event Mint(address indexed who, uint256 tokenId, bytes32 salt, address addressPrecomputed);
  event DeployPriceSet(uint256 indexed chainId, uint256 price);
  event WantDeploy(uint256 chainId, bytes bytecode);

  error UsedHash();
  error CommittedHash();
  error HashNotFound();
  error RecoverError(ECDSAUpgradeable.RecoverError);
  error WrongSigner();
  error TokenLocked();
  error WrongChainIds();
  error HashAlreadyUsed();
  error AddressWasDeployed();

  function _factoryAddress(bytes32 salt) internal pure returns (address factoryAddressPrecomputed) {
    address mainFactory = 0xfBA25AcF53b559eA4feB3ed69F357189FCc4F421;
    bytes memory creationCode = abi.encodePacked(uint184(0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000), uint160(0xdA0741E313711FE2586A4Ffe6e52E27D08826b09), uint120(0x5af43d82803e903d91602b57fd5bf3));
    factoryAddressPrecomputed = address(uint160(uint256(keccak256(abi.encodePacked(
      bytes1(0xff),
      address(mainFactory),
      salt,
      keccak256(creationCode)
    )))));
  }

  function _precompute(address mainFactory, bytes32 salt) internal pure returns (address) {
    bytes memory creationCode = abi.encodePacked(uint184(0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000), uint160(0xdA0741E313711FE2586A4Ffe6e52E27D08826b09), uint120(0x5af43d82803e903d91602b57fd5bf3));
    address factoryAddressPrecomputed = address(uint160(uint256(keccak256(abi.encodePacked(
      bytes1(0xff),
      address(mainFactory),
      salt,
      keccak256(creationCode)
    )))));
    uint8 _nonce = 1; uint8 rlpThing1 = 0xd6; uint8 rlpThing2 = 0x94;
    // S.O.: https://ethereum.stackexchange.com/a/47083/72642
    return address(uint160(uint256(keccak256(abi.encodePacked(rlpThing1, rlpThing2, factoryAddressPrecomputed, _nonce)))));
  }
}
