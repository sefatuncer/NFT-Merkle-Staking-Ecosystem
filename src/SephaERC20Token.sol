// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title SephaERC20Token
 * @notice This is a simple ERC20 token contract with minting ability.
 * @dev This contract extends the OpenZeppelin ERC20 and Ownable2Step contracts.
 */
contract SephaERC20Token is ERC20, Ownable2Step {
    /**
     * @notice Initializes the contract with the name "SephaERC20Token" and the symbol "STR".
     * @dev Mints an initial supply of tokens to the creator's address.
     */
    constructor() ERC20("SephaERC20Token", "STR") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    /**
     * @notice Mint new tokens to a specific address.
     * @dev Only callable by the contract owner.
     * @param to The address to receive the newly minted tokens.
     * @param amount The amount of new tokens to mint.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
