# NFT-MerkleStaking-Ecosystem

This repository contains a trio of smart contracts that integrate various functionalities like ERC721 NFTs with merkle tree discounts, an ERC20 token, and a staking contract.

## Features

1. **ERC721 NFT Contract**
    - A supply of 20 NFTs.
    - ERC 2918 royalty implementation with a reward rate of 2.5% for any NFT in the collection.
    - OpenZeppelin's ERC 2918 royalty is used.
    - Merkle tree discount functionality: Addresses listed in a merkle tree can mint NFTs at a discounted rate. Uses OpenZeppelin's bitmap.

2. **ERC20 Token Contract**
    - Serves as a reward for staking.
    - Tokenomics can be customized as per requirements.

3. **Staking Contract**
    - Users can stake their NFTs using `safeTransfer`.
    - Upon staking an NFT, users can withdraw 10 ERC20 tokens every 24 hours. Proper handling of decimal places is ensured.
    - The NFT can be withdrawn by the original staker at any time.
    - Funds from the NFT sale within the contract can be withdrawn by the owner using the `Ownable2Step` mechanism.

## Gas Optimization

A combination of unit tests and the gas profiler in either Foundry or Hardhat is employed to measure the gas cost of various operations, ensuring that the contracts are efficient and cost-effective.

## Setup and Installation

[Details on how to set up, install, and run the contracts]

## Testing

[Details on how to run the tests and expected outcomes]

## Gas Profiling

[Details on how to profile the gas cost for different operations]

## Contribution

Feel free to contribute to this repository by submitting pull requests or opening issues.

## License

[Your License Here]
