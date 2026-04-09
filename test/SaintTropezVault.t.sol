// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../src/SaintTropezVault.sol";

/**
 * @title SaintTropezVaultTest
 * @dev Automated tests for validating the Chainlink Automation integration 
 * and yield distribution proportionality.
 */
contract SaintTropezVaultTest is Test, IERC1155Receiver {
    SaintTropezVault public vault;
    
    address public admin = address(this);
    address public user = address(0xABC);
    uint256 public constant ASSET_ID = 1;

    function setUp() public {
        vault = new SaintTropezVault();
        
        // Setup initial roles and whitelist
        vault.addToWhitelist(admin);
        vault.addToWhitelist(user);
        
        // Fund admin for yield deposits
        vm.deal(admin, 100 ether);
    }

    /**
     * @dev Core test: Verifies that Chainlink Automation correctly identifies 
     * and distributes yield to investors automatically.
     */
    function test_AutomatedYieldDistribution() public {
        // 1. Setup: Create a fractionalized asset (e.g., Villa in Saint-Tropez)
        uint256 totalSupply = 1000;
        vault.fractionalizeAsset(ASSET_ID, totalSupply, "Villa Gassin", 5_000_000);
        
        // 2. Distribute shares: User acquires 50% of the asset
        uint256 userShares = 500;
        vault.safeTransferFrom(admin, user, ASSET_ID, userShares, ""); 

        // 3. Deposit Yield: Asset Manager deposits 10 ETH from rental income
        uint256 yieldAmount = 10 ether;
        vault.depositYield{value: yieldAmount}(ASSET_ID);

        // 4. Simulate Chainlink Automation "Check" (Off-chain trigger)
        bytes memory checkData = abi.encode(ASSET_ID);
        (bool upkeepNeeded, bytes memory performData) = vault.checkUpkeep(checkData);
        
        assertTrue(upkeepNeeded, "Automation: Upkeep should be triggered after yield deposit");

        // 5. Simulate Chainlink Automation "Perform" (On-chain execution)
        uint256 initialUserBalance = user.balance;
        vault.performUpkeep(performData);

        // 6. Verification: 
        // User should have received exactly 50% of the 10 ETH deposit
        uint256 expectedYield = (yieldAmount * userShares) / totalSupply;
        assertEq(
            user.balance - initialUserBalance, 
            expectedYield, 
            "Automation: Proportional yield distribution failed"
        );
        
        // 7. Internal State Check: Ensure the vault records the payment correctly
        uint256 claimedRecord = vault.claimedYield(user, ASSET_ID);
        assertEq(claimedRecord, expectedYield, "Internal Audit: Claimed yield state mismatch");
    }

    /**
     * @dev Ensures the system remains secure and only processes valid assets.
     */
    function test_UpkeepNotNeededIfNoYield() public {
        uint256 emptyAssetId = 99;
        vault.fractionalizeAsset(emptyAssetId, 100, "Empty Plot", 1_000_000);
        
        bytes memory checkData = abi.encode(emptyAssetId);
        (bool upkeepNeeded, ) = vault.checkUpkeep(checkData);
        
        assertFalse(upkeepNeeded, "Security: Upkeep should not trigger without yield deposit");
    }

    // --- ERC1155 Receiver Compliance for Tests ---

    function onERC1155Received(address, address, uint256, uint256, bytes memory) 
        public 
        pure 
        override 
        returns (bytes4) 
    {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) 
        public 
        pure 
        override 
        returns (bytes4) 
    {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}