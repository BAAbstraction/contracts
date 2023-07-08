// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract IntermediateFactory is Ownable {
  function deploy(bytes memory code) external onlyOwner returns (address) {
    address addr;

    assembly {
      addr := create(0, add(code, 0x20), mload(code))
      if iszero(extcodesize(addr)) {
        revert(0, 0)
      }
    }
    return addr;
  }
}
