// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC721A } from "ERC721A/ERC721A.sol";
import { Constants } from "./Constants.sol";
import { IntermediateFactory } from "./IntermediateFactory.sol";

contract NFTOptions is ERC721A("NFT Address Options", "NOO"), Constants {
  mapping (bytes32 => bool) private hashUsed;
  mapping (bytes32 => address) private whoCommited;
  mapping (uint256 => bytes32) public tokenIdToSalt;
  mapping (uint256 => address) public tokenIdToAddress;

  function _startTokenId() internal pure override returns (uint256) {
    return 1;
  }

  function commit(bytes32 hash) external {
    if (hashUsed[hash] != false) revert UsedHash();
    if (whoCommited[hash] != address(0)) revert CommittedHash();
    whoCommited[hash] = msg.sender;
    emit Commit(msg.sender, hash);
  }

  function mint(bytes32 salt) external {
    bytes32 hash = keccak256(abi.encodePacked(salt)); // TODO add salt for salt :)
    if (whoCommited[hash] != msg.sender) revert HashNotFound();
    require(hashUsed[hash] == false, "NFTOptions: hash already used");
    hashUsed[hash] = true;
    whoCommited[hash] = address(0);
    uint256 id = _nextTokenId();
    _mint(msg.sender, 1);
    tokenIdToSalt[id] = salt;
    emit Mint(msg.sender, id, salt);
  }

  function deploy(uint256 tokenId, bytes memory code) external {
    bytes32 salt = tokenIdToSalt[tokenId];
    IntermediateFactory factory;
    assembly {
      factory := create2(0, add(code, 0x20), mload(code), salt)
      if iszero(extcodesize(factory)) {
        revert(0, 0)
      }
    }
    factory.deploy(code);
  }
}
