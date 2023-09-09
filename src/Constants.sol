// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IntermediateFactory } from "./IntermediateFactory.sol";
import { ECDSA } from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

abstract contract Constants {
  event Commit(address indexed who, bytes32 hash);
  event Mint(address indexed who, uint256 tokenId, bytes32 salt, address addressPrecomputed);
  event DeployPriceSet(uint256 indexed chainId, uint256 price);
  event WantDeploy(uint256 chainId, bytes bytecode);

  error UsedHash();
  error CommittedHash();
  error HashNotFound();
  error RecoverError(ECDSA.RecoverError);
  error WrongSigner();
  error TokenLocked();
  error WrongChainIds();
  error HashAlreadyUsed();

  function _precompute(address mainFactory, bytes32 salt) internal pure returns (address) {
    address factoryAddressPrecomputed = address(uint160(uint256(keccak256(abi.encodePacked(
      bytes1(0xff),
      address(mainFactory),
      salt,
      keccak256(type(IntermediateFactory).creationCode)
    )))));
    uint8 _nonce = 1; uint8 rlpThing1 = 0xd6; uint8 rlpThing2 = 0x94;
    // SO: https://ethereum.stackexchange.com/a/47083/72642
    return address(uint160(uint256(keccak256(abi.encodePacked(rlpThing1, rlpThing2, factoryAddressPrecomputed, _nonce)))));
  }
}
