// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC721Enumerable, ERC721 } from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { Constants } from "./Constants.sol";
import { IntermediateFactory } from "./IntermediateFactory.sol";

contract NFTOptions is ERC721Enumerable, Constants {
  mapping (bytes32 => bool) private hashUsed;
  mapping (bytes32 => address) private whoCommited;
  mapping (uint256 => bytes32) public tokenIdToSalt;
  mapping (uint256 => address) public tokenIdToAddress;

  string public metaUri;

  constructor(string memory _metaUri) ERC721("NFT Address Option", "OPT") {
    metaUri = _metaUri;
  }

  function commit(bytes32 hash) external {
    if (hashUsed[hash] != false) revert UsedHash();
    if (whoCommited[hash] != address(0)) revert CommittedHash();
    whoCommited[hash] = msg.sender;
    emit Commit(msg.sender, hash);
  }

  function mint(bytes32 salt) external {
    bytes32 hash = keccak256(abi.encodePacked(salt)); // TODO add salt for salt :)
    address addressPrecomputed = _precompute(address(this), salt);
    uint256 tokenId = uint256(uint160(addressPrecomputed));

    if (whoCommited[hash] != msg.sender) revert HashNotFound();
    require(hashUsed[hash] == false, "NFTOptions: hash already used");
    hashUsed[hash] = true;
    whoCommited[hash] = address(0);
    _mint(msg.sender, tokenId);
    tokenIdToSalt[tokenId] = salt;
    tokenIdToAddress[tokenId] = addressPrecomputed; // TODO no need?
    emit Mint(msg.sender, tokenId, salt, addressPrecomputed);
  }

  function deploy(uint256 tokenId, bytes memory code) external {
    bytes32 salt = tokenIdToSalt[tokenId];
    IntermediateFactory factory;
    bytes memory factoryCode = type(IntermediateFactory).creationCode;
    assembly {
      factory := create2(0, add(factoryCode, 0x20), mload(factoryCode), salt)
      if iszero(extcodesize(factory)) {
        revert(0, 0)
      }
    }
    factory.deploy(code);
    _burn(tokenId);
  }

  function deploySafe(
    uint256 tokenId,
    address[] calldata _owners,
    uint256 _threshold
  ) external {
    bytes32 salt = tokenIdToSalt[tokenId];
    IntermediateFactory factory;
    bytes memory factoryCode = type(IntermediateFactory).creationCode;
    assembly {
      factory := create2(0, add(factoryCode, 0x20), mload(factoryCode), salt)
      if iszero(extcodesize(factory)) {
        revert(0, 0)
      }
    }
    factory.deploySafeClone(_owners, _threshold);
    _burn(tokenId);
  }

  // override ERC721 methods
  function _baseURI() internal view override returns (string memory) {
    return metaUri;
  }
}
