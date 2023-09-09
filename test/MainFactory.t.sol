// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MainFactory.sol";
import "../src/Constants.sol";

contract MainFactoryTest is Test, Constants {
  MainFactory public mainFactory;
  address public user1 = address(0x123);

  function setUp() public {
    vm.deal(user1, 100 ether);
    mainFactory = new MainFactory("", new uint256[](0), new uint256[](0));
    vm.startPrank(user1);
  }

  function testCommitRevealMint() public {
    bytes32 salt = bytes32(uint256(keccak256(abi.encodePacked("salt"))));
    bytes32 wrongSalt = bytes32(uint256(keccak256(abi.encodePacked("wrongSalt"))));
    bytes32 hash = keccak256(abi.encodePacked(salt));
    vm.expectEmit(true, false, false, true);
    emit Commit(user1, hash);
    mainFactory.commit(hash);
    vm.expectRevert(CommittedHash.selector);
    mainFactory.commit(hash);

    vm.expectRevert(HashNotFound.selector);
    mainFactory.mint(wrongSalt);

    address precomputed = _precompute(address(mainFactory), salt);
    uint256 tokenId = uint256(uint160(precomputed));

    vm.expectEmit(true, false, false, true);
    emit Mint(user1, tokenId, salt, precomputed);
    mainFactory.mint(salt);

    bytes memory sampleCode = type(IntermediateFactory).creationCode;
    mainFactory.deploy(tokenId, sampleCode);


    // TODO used hash
  }
}
