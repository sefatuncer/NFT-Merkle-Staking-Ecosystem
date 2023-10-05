// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/StakingContract.sol";
import "../src/SephaNFT.sol";
import "../src/SephaERC20Token.sol";

contract StakingContractTest is Test {
    StakingContract public stakingContract;
    SephaERC20Token public rewardToken;
    SephaNFT public sephanft;

    // address constant OWNER = address(0x5E11E7);
    address public OWNER = address(this);
    address public user1 = address(0x5E11E7);

    bytes32 constant MERKLE_ROOT = bytes32("0x5E11E7");

    event Staked(address indexed user, uint256 tokenId);
    event Unstaked(address indexed user, uint256 tokenId);
    event RewardsWithdrawn(address indexed user, uint256 amount);

    function setUp() public {
        vm.prank(OWNER, user1);
        rewardToken = new SephaERC20Token();  // Assuming you have imported the contracts and they have constructors without parameters
        sephanft = new SephaNFT(MERKLE_ROOT);
        stakingContract = new StakingContract(address(sephanft), address(rewardToken));
    }

    modifier startAtPresentDay() {
        vm.warp(1680616584);
        _;
    }

    function testStakeNFT() public startAtPresentDay {
        vm.startPrank(OWNER);
        uint256 tokenId = 0;
        sephanft.mintNFT(OWNER);
        sephanft.approve(address(stakingContract), tokenId);
        assertEq(sephanft.ownerOf(tokenId), OWNER, "Ownership mismatch");
        stakingContract.stakeNFT(tokenId);
        assertEq(sephanft.ownerOf(tokenId), address(stakingContract), "Staking contract should own NFT");
        // vm.expectEmit();
        // emit Staked(OWNER, tokenId);
        vm.stopPrank();
    }

    function testUnstakeNFT() public startAtPresentDay {
        vm.startPrank(OWNER);
        uint256 tokenId = 0;
        sephanft.mintNFT(user1);
        sephanft.approve(address(stakingContract), tokenId);
        stakingContract.stakeNFT(tokenId);
        vm.stopPrank();

        vm.startPrank(user1);
        stakingContract.unstakeNFT(tokenId);
        assertEq(sephanft.ownerOf(tokenId), user1, "Should revert ownership");
        // vm.expectEmit();
        // emit Unstaked(OWNER, 0);
        vm.stopPrank();
    }

    function testWithdrawRewards() public startAtPresentDay {
        vm.startPrank(OWNER);
        rewardToken.mint(address(stakingContract), 100 * 10 ** rewardToken.decimals());
        sephanft.mintNFT(OWNER);
        stakingContract.stakeNFT(0);
        vm.warp(1680616584 + 1 days + 1);
        stakingContract.withdrawRewards();
        uint256 amount = 10 * 10 ** uint256(rewardToken.decimals());
        assertEq(rewardToken.balanceOf(OWNER), amount, "Rewards not received correctly");
        vm.expectEmit();
        emit RewardsWithdrawn(OWNER, amount);
        vm.stopPrank();
    }

    function testFailWithdrawRewardsEarly() public startAtPresentDay {
        vm.startPrank(OWNER);
        rewardToken.mint(address(stakingContract), 100 * 10 ** rewardToken.decimals());
        sephanft.mintNFT(OWNER);
        stakingContract.stakeNFT(0);
        vm.expectRevert();
        stakingContract.withdrawRewards();
    }
}
