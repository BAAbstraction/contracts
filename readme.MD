Hi, future me and others.

To deploy:
```
forge script script/NFTOptions.deploy.sol --rpc-url https://gnosis.api.onfinality.io/public --private-key ... --broadcast
```

To verify:
```
forge verify-contract --chain 100 --etherscan-api-key ... <contract address> NFTOptions --verifier-url https://api.gnosisscan.io/api --watch --verifier etherscan --constructor-args 0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002068747470733a2f2f6d6574612e616464726573732d6f7074696f6e2e636f6d2f
```

To test - `forge test -vvvv`

