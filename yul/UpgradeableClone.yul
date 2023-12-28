object "UpgradeableClone" {
  code {
    datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    return(0, datasize("Runtime"))
  }
  object "Runtime" {
    code {
      let impl := sload(0)
      switch impl
      case 0 {
        sstore(address(), calldataload(0))
      }
      default {
        calldatacopy(0, 0, calldatasize())
        let success := delegatecall(
          gas(),
          impl,
          returndatasize(),
          calldatasize(),
          returndatasize(),
          returndatasize()
        )
        returndatacopy(0, 0, returndatasize())
        if iszero(success) {
          revert (zero,returndatasize())
        }
        return (zero,returndatasize())
      }
    }
  }
}
