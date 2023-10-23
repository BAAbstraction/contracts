// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/proxy/Clones.sol";
import { SafeInterface } from "./SafeInterface.sol";
import { SafeProxy } from "safe-contracts/contracts/proxies/SafeProxy.sol";


contract DeployDelegates {
  event ProxyCreation(SafeProxy indexed proxy, address singleton);

  function deploy(bytes memory code) external returns (address) {
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
  ) external returns (address) {
    address _singleton = 0x41675C099F32341bf84BFc5382aF534df5C7461a;
    SafeProxy safe = new SafeProxy(_singleton);
    SafeInterface(address(safe)).setup(_owners, _threshold, address(0), bytes(''), 0xf48f2B2d2a534e402487b3ee7C18c33Aec0Fe5e4, address(0), 0, payable(address(0)));
    emit ProxyCreation(safe, _singleton);
    return address(safe);
  }
}
