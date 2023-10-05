// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "lib/forge-std/src/Test.sol";
import "lib/forge-std/src/Vm.sol";
import "../src/SephaERC20Token.sol";

contract SephaERC20TokenTest is Test {
    SephaERC20Token public token;
    address public owner;

    function setUp() public {
        owner = address(this);
        token = new SephaERC20Token();
    }

    // Test initial token balance of contract creator
    function testInitialState() public {
        uint256 expected = 1000000 * 10 ** 18;
        assertEq(token.balanceOf(owner), expected, "Initial balance should match the initial supply");
    }

    // Test mint function
    function testMint() public {
        uint256 amountToMint = 1000 * 10 ** 18;
        uint256 expectedBalance = 1001000 * 10 ** 18;

        //Owner should be able to mint tokens
        token.mint(owner, amountToMint);

        assertEq(token.balanceOf(owner), expectedBalance, "Balance should increase after minting");
    }
}
