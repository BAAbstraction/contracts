// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/NFTOptions.sol";

contract NFTOptionsTest is Test {
    NFTOptions public nftOptions;

    function setUp() public {
        nftOptions = new NFTOptions();
    }

    function testIncrement() public {
        
    }
}
