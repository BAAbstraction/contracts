// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface SafeInterface {
  function setup(
      address[] calldata _owners,
      uint256 _threshold,
      address to,
      bytes calldata data,
      address fallbackHandler,
      address paymentToken,
      uint256 payment,
      address payable paymentReceiver
  ) external;
}
