# AZC Smart Contracts 🚀

> This repository contains the core smart contracts used by the AZC crypto project.

## Deployment

```shell
npx hardhat compile
npx hardhat deploy --network bsc_mainnet --task "deploy-treasury" --stage bsc_mainnet
npx hardhat deploy --network bsc_mainnet --task "deploy-azToken" --stage bsc_mainnet
npx hardhat deploy --network bsc_mainnet --task "deploy-template" --stage bsc_mainnet
npx hardhat deploy --network bsc_mainnet --task "deploy-distributor" --stage bsc_mainnet
```

## Included Smart Contracts

| Sourcefile                                               | Description |
|----------------------------------------------------------|---|
| [AZCoiner.sol](contracts/AZCoiner.sol) | This is a Solidity smart contract that represents the AZC token. The AZC token is a capped BEP20 token that can be minted and burned.
| [Treasury.sol](contracts/Treasury.sol) | This is a simple Solidity smart contract that manages a token resource and access rights to mint a specific type of token.
| [Distributor.sol](contracts/Distributor.sol) | This is a Solidity smart contract that manage token distribution through different vesting wallets.

## Token Information

- **Mainnet address:** [0x2eAf707440974deba88F5b2425caDcc4821aA954](https://bscscan.com/token/0x2eAf707440974deba88F5b2425caDcc4821aA954)
- **Audit:** [Cyberscope](audit.pdf)