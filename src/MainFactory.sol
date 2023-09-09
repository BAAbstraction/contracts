// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC721Enumerable, ERC721 } from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { Constants } from "./Constants.sol";
import { IntermediateFactory } from "./IntermediateFactory.sol";
import { ECDSA } from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract MainFactory is ERC721Enumerable, Constants, Ownable {
  using ECDSA for bytes32;

  mapping (bytes32 => bool) private hashUsed;
  mapping (bytes32 => address) private whoCommited;
  mapping (uint256 => bytes32) public tokenIdToSalt;
  mapping (uint256 => bool) public permanentLock;

  mapping (uint256 => uint256) public deployPrices;

  string public metaUri;
  uint256[50] gap;

  constructor(
    string memory _metaUri,
    uint256[] memory _chainIds,
    uint256[] memory _prices
  ) ERC721("NFT Address Option", "OPT") {
    metaUri = _metaUri;
    _setDeployPrices(_chainIds, _prices);
  }

  function _setDeployPrices(uint256[] memory chainIds, uint256[] memory prices) private {
    if (chainIds.length != prices.length) {
      revert WrongChainIds();
    }
    for (uint256 i = 0; i < chainIds.length; i++) {
      deployPrices[chainIds[i]] = prices[i];
      emit DeployPriceSet(chainIds[i], prices[i]);
    }
  }

  function setDeployPrices(uint256[] calldata chainIds, uint256[] calldata prices) external onlyOwner {
    if (chainIds.length == 0) {
      revert WrongChainIds();
    }
    _setDeployPrices(chainIds, prices);
  }

  function commit(bytes32 hash) external {
    if (hashUsed[hash] != false) revert UsedHash();
    if (whoCommited[hash] != address(0)) revert CommittedHash();
    whoCommited[hash] = msg.sender;
    emit Commit(msg.sender, hash);
  }

  function mint(bytes32 salt) external {
    bytes32 hash = keccak256(abi.encodePacked(salt));
    address addressPrecomputed = _precompute(address(this), salt);
    uint256 tokenId = uint256(uint160(addressPrecomputed));

    if (whoCommited[hash] != msg.sender) revert HashNotFound();
    if (hashUsed[hash]) revert HashAlreadyUsed();
    hashUsed[hash] = true;
    whoCommited[hash] = address(0);
    _mint(msg.sender, tokenId);
    tokenIdToSalt[tokenId] = salt;
    emit Mint(msg.sender, tokenId, salt, addressPrecomputed);
  }

  function _deploy(bytes32 salt, bytes memory code) internal {
    IntermediateFactory factory;
    bytes memory factoryCode = type(IntermediateFactory).creationCode;
    assembly {
      factory := create2(0, add(factoryCode, 0x20), mload(factoryCode), salt)
      if iszero(extcodesize(factory)) {
        revert(0, 0)
      }
    }
    factory.deploy(code); // deploy from factory using create opcode (not create2)
  }

  function deploy(uint256 tokenId, bytes memory code) external {
    bytes32 salt = tokenIdToSalt[tokenId];
    _deploy(salt, code);
    _burn(tokenId);
  }

  // function multichainDeploy(
  //   uint256 tokenId,
  //   bytes memory baseChainCode,
  //   uint256[] calldata chainIds,
  //   bytes[] memory bytecodes
  // ) external {
  //   bytes32 salt = tokenIdToSalt[tokenId];
  //   if (baseChainCode != bytes()) {
  //     _deploy(salt, baseChainCode);
  //   }
  //   if (chainIds.length != bytecodes.length) {
  //     revert WrongChainIds();
  //   }
  //   for (uint256 i = 0; i < chainIds.length; i++) {
  //     if (deployPrices[chainIds[i]] == 0) {
  //       revert WrongChainIds();
  //     }
      
  //   }
  // }

  function deployBySignature(
    bytes32 salt,
    bytes memory code,
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external {
    (address signer, ECDSA.RecoverError error) = hash.tryRecover(v, r, s);
    if (error != ECDSA.RecoverError.NoError) {
      revert RecoverError(error);
    }
    if (signer != msg.sender) {
      revert WrongSigner();
    }
    _deploy(salt, code);
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
    factory.deploySafeClone(_owners, _threshold); // deploy from factory using create opcode (not create2)
    _burn(tokenId);
  }

  // override ERC721 methods
  function _baseURI() internal view override returns (string memory) {
    return metaUri;
  }

  function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal view override {
    if (permanentLock[firstTokenId]) {
      revert TokenLocked();
    }
    from; to; batchSize;
  }
}
