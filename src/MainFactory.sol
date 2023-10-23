// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ERC721EnumerableUpgradeable, ERC721Upgradeable } from "oz-upgradeable/contracts/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import { Constants } from "./Constants.sol";
import { IntermediateFactory } from "./IntermediateFactory.sol";
import { ECDSAUpgradeable } from "oz-upgradeable/contracts/utils/cryptography/ECDSAUpgradeable.sol";
import { OwnableUpgradeable } from "oz-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts/contracts/proxy/Clones.sol";
import { console } from "forge-std/console.sol";

contract MainFactory is ERC721EnumerableUpgradeable, Constants, OwnableUpgradeable {
  using ECDSAUpgradeable for bytes32;

  // a proxy of IntermediateFactory, address fixed on every chain permanently
  IntermediateFactory public intermediateFactory;

  string public metaUri;

  mapping (bytes32 => bool) private hashUsed;
  mapping (bytes32 => address) private whoCommited;
  mapping (uint256 => bytes32) public tokenIdToSalt;
  mapping (uint256 => bool) public permanentLock;

  mapping (uint256 => uint256) public deployPrices; // reserved for future use

  uint256[50] _____gap;

  function initialize(IntermediateFactory _intermediateFactory) external initializer { // TODO security when deploying
    __ERC721_init("NFT Address Option", "OPT");
    __ERC721Enumerable_init();
    __Ownable_init();

    intermediateFactory = _intermediateFactory;
  }

  function setMetaUri(string calldata _metaUri) external onlyOwner {
    metaUri = _metaUri;
  }

  // function _setDeployPrices(uint256[] memory chainIds, uint256[] memory prices) private {
  //   if (chainIds.length != prices.length) {
  //     revert WrongChainIds();
  //   }
  //   for (uint256 i = 0; i < chainIds.length; i++) {
  //     deployPrices[chainIds[i]] = prices[i];
  //     emit DeployPriceSet(chainIds[i], prices[i]);
  //   }
  // }

  // function setDeployPrices(uint256[] calldata chainIds, uint256[] calldata prices) external onlyOwner {
  //   if (chainIds.length == 0) {
  //     revert WrongChainIds();
  //   }
  //   _setDeployPrices(chainIds, prices);
  // }

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
    IntermediateFactory intermediateFactoryClone = IntermediateFactory(Clones.cloneDeterministic(address(intermediateFactory), salt));
    console.log("intermediateFactoryClone", address(intermediateFactoryClone));

    // address _intermediateFactory = address(intermediateFactory);
    // bytes memory factoryCode;
    // assembly {
    //   mstore(0x00, or(shr(0xe8, shl(0x60, _intermediateFactory)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
    //   mstore(0x20, or(shl(0x78, _intermediateFactory), 0x5af43d82803e903d91602b57fd5bf3))
    //   factoryCode := mload(0x00)
    // }
    // bytes memory factoryCode = bytes(0x5af43d82803e903d91602b57fd5bf3 | (uint256(uint160(address(intermediateFactory))) << 15) | (0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000 << 35));
    // assembly {
    //   factory := create2(0, add(factoryCode, 0x20), mload(factoryCode), salt)
    //   if iszero(extcodesize(factory)) {
    //     revert(0, 0)
    //   }
    // }
    intermediateFactoryClone.deploy(code); // deploy from factory using create opcode (not create2)
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
    (address signer, ECDSAUpgradeable.RecoverError error) = hash.tryRecover(v, r, s);
    if (error != ECDSAUpgradeable.RecoverError.NoError) {
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
