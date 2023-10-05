// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "lib/forge-std/src/Test.sol";
import "lib/forge-std/src/Vm.sol";
import "../src/SephaNFT.sol";

// SephaNFTTest is the main contract used for testing SephaNFT
contract SephaNFTTest is Test {
    // Instance of the SephaNFT contract
    SephaNFT public sephanft;

    // Constant variable for the mock Merkle Root
    bytes32 constant MERKLE_ROOT = bytes32("0x5E11E7");

    // Initialization of the contract for each test case
    function setUp() public {
        sephanft = new SephaNFT(MERKLE_ROOT);
    }

    // Test case for minting an NFT
    function testMintingNFT() public {
        vm.prank(sephanft.owner()); // Set msg.sender as the owner of SephaNFT
        sephanft.mintNFT(address(this)); // Mint a new NFT to this contract

        // Assertions to check the state
        assertEq(sephanft.totalSupply(), 1, "Total supply should be 1");
        assertEq(sephanft.ownerOf(0), address(this), "Owner should be this contract");
    }

    // for discounted minting test, requires Merkle proof
    // function testDiscountedMintNFT() public {
    //     // Define the Merkle proof
    //     bytes32[] memory proof = new bytes32[](1);
    //     proof[0] = keccak256(abi.encodePacked(MERKLE_ROOT));

    //     vm.prank(sephanft.owner()); // Set msg.sender as the owner
    //     sephanft.discountedMintNFT(proof); // Mint with discount

    //     // Assertions to check the state
    //     assertEq(sephanft.totalSupply(), 1, "Total Supply should be 1");
    //     assertEq(sephanft.ownerOf(0), address(this), "Owner should be this contract");
    // }

    // Test case for maximum supply limit
    function testMaxSupplyLimit() public {
        vm.prank(sephanft.owner()); // Set msg.sender as the owner
        // Loop to mint 20 NFTs, reaching the maximum supply
        for (uint256 i = 0; i < 20; i++) {
            sephanft.mintNFT(address(this));
        }
        vm.expectRevert();
        sephanft.mintNFT(address(this)); // This should revert because max supply has been reached
    }

    // Test case for checking royalty info
    function testRoyaltyInfo() public {
        uint256 initialTotalSupply = sephanft.totalSupply();
        vm.prank(sephanft.owner()); // Set msg.sender as the owner
        sephanft.mintNFT(address(this)); // Mint a new NFT to this contract

        // Fetch the royalty information
        (address receiver, uint256 royaltyAmount) = sephanft.royaltyInfo(initialTotalSupply, 10000);

        // Assertions to check royalty info
        assertEq(receiver, address(sephanft.owner()), "Receiver should be contract owner");
        assertEq(royaltyAmount, 250, "Royalty amount should be 250");
    }

    // Test case for checking if an address is an NFT owner
    function testIsNFTOwner() public {
        vm.prank(sephanft.owner()); // Set msg.sender as the owner
        // Check if not an owner initially
        assertEq(sephanft.isNFTOwner(address(this)), false, "Should not be owner yet");

        sephanft.mintNFT(address(this)); // Mint a new NFT to this contract

        // Check if the contract is now an NFT owner
        assertEq(sephanft.isNFTOwner(address(this)), true, "Should be the owner now");
    }
}
