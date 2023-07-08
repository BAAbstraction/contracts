// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/proxy/Clones.sol";
import { SafeInterface } from "./SafeInterface.sol";


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

  function deploySafeClone(
    address[] calldata _owners,
    uint256 _threshold
  ) external onlyOwner returns (address) {
    address safe = Clones.clone(0x41675C099F32341bf84BFc5382aF534df5C7461a);
    SafeInterface(safe).setup(_owners, _threshold, address(0), bytes(''), address(0), address(0), 0, payable(address(0)));
    return safe;
  }
}
