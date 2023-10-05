// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./SephaNFT.sol";
import "./SephaERC20Token.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract StakingContract is IERC721Receiver, Ownable2Step {
    SephaNFT public sephanft;
    SephaERC20Token public rewardToken;

    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => mapping(uint256 => bool)) public isStaking;  // Mapping from user to token to staking status

    event Staked(address indexed user, uint256 tokenId);
    event Unstaked(address indexed user, uint256 tokenId);
    event RewardsWithdrawn(address indexed user, uint256 amount);

    constructor(address _NFT, address _token) Ownable(msg.sender) {
        sephanft = SephaNFT(_NFT);
        rewardToken = SephaERC20Token(_token);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function stakeNFT(uint256 tokenId) external {
        require(sephanft.ownerOf(tokenId) == msg.sender, "You do not own this NFT");
        require(!isStaking[msg.sender][tokenId], "Token already staked");

        sephanft.safeTransferFrom(msg.sender, address(this), tokenId);
        isStaking[msg.sender][tokenId] = true;
        emit Staked(msg.sender, tokenId);
    }

    function withdrawRewards() external {
        require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 days, "Wait 24 hours between withdrawals");
        lastWithdrawTime[msg.sender] = block.timestamp;

        uint256 amount = 10 * 10 ** uint256(rewardToken.decimals());
        rewardToken.transfer(msg.sender, amount);
        emit RewardsWithdrawn(msg.sender, amount);
    }

    function unstakeNFT(uint256 tokenId) external {
        require(isStaking[msg.sender][tokenId], "Token not staked");

        sephanft.safeTransferFrom(address(this), msg.sender, tokenId);
        isStaking[msg.sender][tokenId] = false;
        emit Unstaked(msg.sender, tokenId);
    }

    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
