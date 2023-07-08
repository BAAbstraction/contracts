// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract Constants {
  event Commit(address indexed who, bytes32 hash);
  event Mint(address indexed who, uint256 tokenId, bytes32 salt);

  error UsedHash();
  error CommittedHash();
  error HashNotFound();
}
