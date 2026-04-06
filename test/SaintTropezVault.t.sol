// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../src/SaintTropezVault.sol";

contract SaintTropezVaultTest is Test, IERC1155Receiver {
    SaintTropezVault public vault;
    
    address public admin = address(this);
    address public user = address(0xABC);
    address public maliciousUser = address(0x666);
    address public nonWhitelisted = address(0xDEAD);

    function setUp() public {
        vault = new SaintTropezVault();
        vault.addToWhitelist(admin);
        vault.addToWhitelist(user);
        vm.deal(admin, 1000000 ether); // Increased admin funds for high-value fuzzing
        vm.deal(user, 10 ether);
    }

    // === 1. Access Control & Revert Tests ===

    /**
     * @dev Ensures that only whitelisted addresses can claim yield.
     */
    function test_RevertIf_NotWhitelisted() public {
        uint256 id = 1;
        vault.fractionalizeAsset(id, 1000, "Villa Gassin", 5_000_000);
        vm.prank(nonWhitelisted);
        vm.expectRevert("Not whitelisted");
        vault.claimYield(id);
    }

    /**
     * @dev Ensures that only accounts with ASSET_MANAGER_ROLE can fractionalize assets.
     */
    function test_RevertIf_NotAssetManager() public {
        vm.startPrank(maliciousUser);
        vm.expectRevert(); 
        vault.fractionalizeAsset(99, 100, "Fake Asset", 1);
        vm.stopPrank();
    }

    /**
     * @dev Ensures that a user cannot claim yield if they don't hold any tokens.
     */
    function test_RevertIf_NoTokensHeld() public {
        uint256 id = 2;
        vault.fractionalizeAsset(id, 1000, "Villa Pampelonne", 10_000_000);
        vault.depositYield{value: 1 ether}(id);
        vm.prank(user);
        vm.expectRevert("No tokens");
        vault.claimYield(id);
    }

    // === 2. Fuzz Testing (Mathematics & Proportionality) ===

    /**
     * @dev Fuzz test for proportional yield distribution.
     * Fixed constraints to prevent arithmetic overflows during multiplication.
     */
    function testFuzz_ClaimYield_Proportional(uint256 depositAmount, uint256 userShare) public {
        // Constraints: Min 0.01 ETH, Max 100,000 ETH to prevent overflow in (yield * balance)
        vm.assume(depositAmount > 1e16 && depositAmount < 100000 ether); 
        // User share must be at least 1 and not exceed total supply
        vm.assume(userShare > 0 && userShare <= 10000); 
        
        uint256 id = 101;
        uint256 totalSupply = 10000;
        
        vault.fractionalizeAsset(id, totalSupply, "Fuzz Estate", 1_000_000);
        vault.safeTransferFrom(admin, user, id, userShare, "");
        
        vault.depositYield{value: depositAmount}(id);
        
        uint256 expectedYield = (depositAmount * userShare) / totalSupply;
        uint256 initialBalance = user.balance;
        
        vm.prank(user);
        vault.claimYield(id);
        
        assertEq(user.balance - initialBalance, expectedYield, "Yield distribution mismatch");
    }

    // === 3. Invariant & Edge Case Tests ===

    /**
     * @dev Invariant test: claimed yield should never exceed deposit.
     */
    function test_Invariant_TotalClaimedNotExceedsDeposit() public {
        uint256 id = 202;
        uint256 depositAmt = 5 ether;
        vault.fractionalizeAsset(id, 1000, "Invariant Property", 1_000_000);
        vault.depositYield{value: depositAmt}(id);
        vault.safeTransferFrom(admin, user, id, 1000, "");
        vm.prank(user);
        vault.claimYield(id);
        uint256 totalClaimedByAccount = vault.claimedYield(user, id);
        assertLe(totalClaimedByAccount, depositAmt, "Claimed amount exceeds deposit");
    }

    // === 4. ERC1155 Receiver Support & Interface ===

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}