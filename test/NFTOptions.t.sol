// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/NFTOptions.sol";
import "../src/Constants.sol";

contract NFTOptionsTest is Test, Constants {
  NFTOptions public nftOptions;
  address public user1 = address(0x123);

  function setUp() public {
    vm.deal(user1, 100 ether);
    nftOptions = new NFTOptions("");
    vm.startPrank(user1);
  }

  function testCommitRevealMint() public {
    bytes32 salt = bytes32(uint256(keccak256(abi.encodePacked("salt"))));
    bytes32 wrongSalt = bytes32(uint256(keccak256(abi.encodePacked("wrongSalt"))));
    bytes32 hash = keccak256(abi.encodePacked(salt));
    vm.expectEmit(true, false, false, true);
    emit Commit(user1, hash);
    nftOptions.commit(hash);
    vm.expectRevert(CommittedHash.selector);
    nftOptions.commit(hash);

    vm.expectRevert(HashNotFound.selector);
    nftOptions.mint(wrongSalt);

    address precomputed = _precompute(address(nftOptions), salt);
    uint256 tokenId = uint256(uint160(precomputed));

    vm.expectEmit(true, false, false, true);
    emit Mint(user1, tokenId, salt, precomputed);
    nftOptions.mint(salt);

    bytes memory sampleCode = type(IntermediateFactory).creationCode;
    nftOptions.deploy(tokenId, sampleCode);


    // TODO used hash
  }
}
