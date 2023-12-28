// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721EnumerableUpgradeable, ERC721Upgradeable} from "openzeppelin/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import {Constants} from "./Constants.sol";
import {IntermediateFactory} from "./IntermediateFactory.sol";
import {ECDSAUpgradeable} from "openzeppelin/utils/cryptography/ECDSAUpgradeable.sol";
import {OwnableUpgradeable} from "openzeppelin/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts/contracts/proxy/Clones.sol";
import {console} from "forge-std/console.sol";
import {console2} from "forge-std/console2.sol";

contract MainFactory is
  ERC721EnumerableUpgradeable,
  Constants,
  OwnableUpgradeable
{
  using ECDSAUpgradeable for bytes32;

  // a proxy of IntermediateFactory, address fixed on every chain permanently
  IntermediateFactory public intermediateFactory;

  string public metaUri;

  mapping(bytes32 => bool) private hashUsed;
  mapping(bytes32 => address) private whoCommited;
  mapping(uint256 => bytes32) public tokenIdToSalt;
  mapping(uint256 => bool) public permanentLock;

  mapping(uint256 => uint256) public deployPrices; // reserved for future use

  uint256[50] _____gap;

  function initialize(
    IntermediateFactory _intermediateFactory
  ) external initializer {
    // TODO security when deploying
    __ERC721_init("NFT Address Option", "OPT");
    __ERC721Enumerable_init();
    __Ownable_init();

    intermediateFactory = _intermediateFactory;
  }

  function setMetaUri(string calldata _metaUri) external onlyOwner {
    metaUri = _metaUri;
  }

  function commit(bytes32 _hash) external {
    if (hashUsed[_hash] != false) revert UsedHash();
    if (whoCommited[_hash] != address(0)) revert CommittedHash();
    whoCommited[_hash] = msg.sender;
    emit Commit(msg.sender, _hash);
  }

  function reveal(bytes32 salt, uint256 randomFactor) external returns (uint256 tokenId) {
    bytes32 _hash = keccak256(abi.encodePacked(salt, randomFactor));
    address addressPrecomputed = _precompute(address(this), salt);
    tokenId = uint256(uint160(addressPrecomputed));

    if (whoCommited[_hash] != msg.sender) {
      revert HashNotFound();
    }
    if (hashUsed[_hash]) {
      revert HashAlreadyUsed();
    }
    if (tokenIdToSalt[tokenId] != 0) {
      revert AddressWasDeployed();
    }
    hashUsed[_hash] = true;
    whoCommited[_hash] = address(0);
    _mint(msg.sender, tokenId);
    tokenIdToSalt[tokenId] = salt;
    emit Mint(msg.sender, tokenId, salt, addressPrecomputed);
  }

  function _deploy(bytes32 salt, bytes memory code) internal {
    IntermediateFactory intermediateFactoryClone = IntermediateFactory(
      Clones.cloneDeterministic(address(intermediateFactory), salt)
    );
    console2.logBytes(address(intermediateFactoryClone).code);
    console.log(
      "intermediateFactory",
      address(intermediateFactory)
    );
    console2.logBytes32(salt);
    console.log(
      "intermediateFactoryClone",
      address(intermediateFactoryClone)
    );

    intermediateFactoryClone.deploy(code); // deploy from factory using create opcode (not create2)
    // intermediateFactoryClone.destroy();
  }

  event Salt(bytes32);

  function deploy(uint256 tokenId, bytes memory code) external {
    // TODO check owner
    bytes32 salt = tokenIdToSalt[tokenId];
    emit Salt(salt);
    _deploy(salt, code);
    _burn(tokenId);
  }

  // function deployBySignature(
  //   bytes32 salt,
  //   bytes memory code,
  //   bytes32 hash,
  //   uint8 v,
  //   bytes32 r,
  //   bytes32 s
  // ) external {
  //   (address signer, ECDSAUpgradeable.RecoverError error) = hash.tryRecover(
  //     v,
  //     r,
  //     s
  //   );
  //   if (error != ECDSAUpgradeable.RecoverError.NoError) {
  //     revert RecoverError(error);
  //   }
  //   if (signer != msg.sender) {
  //     revert WrongSigner();
  //   }
  //   _deploy(salt, code);
  // }

  // function deploySafe(
  //   uint256 tokenId,
  //   address[] calldata _owners,
  //   uint256 _threshold
  // ) external {
  //   bytes32 salt = tokenIdToSalt[tokenId];
  //   IntermediateFactory factory;
  //   bytes memory factoryCode = type(IntermediateFactory).creationCode;
  //   assembly {
  //     factory := create2(
  //       0,
  //       add(factoryCode, 0x20),
  //       mload(factoryCode),
  //       salt
  //     )
  //     if iszero(extcodesize(factory)) {
  //       revert(0, 0)
  //     }
  //   }
  //   factory.deploySafeClone(_owners, _threshold); // deploy from factory using create opcode (not create2)
  //   _burn(tokenId);
  // }

  // override ERC721 methods
  function _baseURI() internal view override returns (string memory) {
    return metaUri;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 firstTokenId,
    uint256 batchSize
  ) internal view override {
    if (permanentLock[firstTokenId] && to != address(0)) {
      revert TokenLocked();
    }
    from;
    to;
    batchSize;
  }
}
