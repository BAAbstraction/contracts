// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MainFactory.sol";
import "../src/IntermediateFactory.sol";
import "../src/Constants.sol";
import { console } from "forge-std/console.sol";
import { TransparentUpgradeableProxy, ITransparentUpgradeableProxy } from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";


contract MainFactoryTest is Test, Constants {
  event Bbb(bytes);
  MainFactory public mainFactory;
  IntermediateFactory public intermediateFactory;

  address constant _OWNER = 0x90Ad080DBfd9cB333bA200025f3a2666071555D9;

  function setUp() public {
    vm.startPrank(_OWNER);
    vm.deal(_OWNER, 100 ether);
    console.log("owner: %s", _OWNER);
    // 3) deploy IF-Implementation
    IntermediateFactory _intermediateFactory = new IntermediateFactory();
    // 4) deploy MF-Implementation
    MainFactory _mainFactory = new MainFactory();
    // 1) deploy IF-Proxy
    ITransparentUpgradeableProxy IFP = ITransparentUpgradeableProxy(address(new TransparentUpgradeableProxy(
      address(_intermediateFactory),
      msg.sender,
       abi.encodeWithSelector(IntermediateFactory.initialize.selector)
    )));
    console.log("IFP: %s", address(IFP));
    // 2) deploy MF-Proxy
    ITransparentUpgradeableProxy MFP = ITransparentUpgradeableProxy(address(new TransparentUpgradeableProxy(
      address(_mainFactory),
      msg.sender,
      abi.encodeWithSelector(MainFactory.initialize.selector, _intermediateFactory)
    )));
    console.log("MFP: %s", address(MFP));

    mainFactory = MainFactory(address(MFP));
    intermediateFactory = IntermediateFactory(address(IFP));
  }

  function testCommitRevealMint() public {
    console.log('precomp addr', _precompute(0xfBA25AcF53b559eA4feB3ed69F357189FCc4F421, bytes32(uint256(6167569445235488))));

    uint8 nonce = 0;
    bytes32 salt = bytes32(uint256(keccak256(abi.encodePacked("salt"))));
    bytes32 wrongSalt = bytes32(uint256(keccak256(abi.encodePacked("wrongSalt"))));
    bytes32 _hash = keccak256(abi.encodePacked(salt, nonce));
    vm.expectEmit(true, false, false, true);
    emit Commit(_OWNER, _hash);
    mainFactory.commit(_hash);
    vm.expectRevert(CommittedHash.selector);
    mainFactory.commit(_hash);

    vm.expectRevert(HashNotFound.selector);
    mainFactory.reveal(wrongSalt, nonce);

    address precomputed = _precompute(address(mainFactory), salt);
    uint256 tokenId = uint256(uint160(precomputed));

    vm.expectEmit(true, false, false, true);
    emit Mint(_OWNER, tokenId, salt, precomputed);
    mainFactory.reveal(salt, nonce);

    bytes memory sampleCode = type(IntermediateFactory).creationCode;
    mainFactory.deploy(tokenId, sampleCode);


    // TODO used hash
  }
}
