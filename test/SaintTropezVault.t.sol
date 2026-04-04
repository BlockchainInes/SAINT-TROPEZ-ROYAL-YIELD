// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SaintTropezVault.sol";

contract SaintTropezVaultTest is Test {
    
    SaintTropezVault public vault;

    address public owner = makeAddr("owner");
    address public securityOfficer = makeAddr("securityOfficer");
    address public assetManager = makeAddr("assetManager");
    address public investor1 = makeAddr("investor1");
    address public nonWhitelisted = makeAddr("nonWhitelisted");

    uint256 public constant TOKEN_ID = 1;
    uint256 public constant SUPPLY = 1000;
    string public constant ASSET_NAME = "Villa Azure";
    uint256 public constant VALUATION = 5_000_000 ether;

    event AssetFractionalized(uint256 indexed id, string name, uint256 valuation, uint256 yieldRate, uint256 supply);
    event WhitelistUpdated(address indexed investor, bool status);

    function setUp() public {
        vm.startPrank(owner);
        vault = new SaintTropezVault();
        
        vault.grantRole(vault.SECURITY_OFFICER_ROLE(), securityOfficer);
        vault.grantRole(vault.ASSET_MANAGER_ROLE(), assetManager);
        vault.addToWhitelist(owner);           // Owner kann initial transferieren
        
        vm.stopPrank();
    }

    // ==================== BASIC TESTS ====================

    function test_Deployment_SetsOwnerAsAdmin() public view {
        assertTrue(vault.hasRole(vault.DEFAULT_ADMIN_ROLE(), owner));
    }

    function test_Deployment_SetsCorrectUri() public view {
        assertEq(vault.uri(TOKEN_ID), "https://api.sainttropez-yield.io/metadata/{id}.json");
    }

    // ==================== WHITELIST TESTS ====================

    function test_SecurityOfficer_CanAddToWhitelist() public {
        vm.prank(securityOfficer);
        vm.expectEmit(true, false, false, true);
        emit WhitelistUpdated(investor1, true);
        
        vault.addToWhitelist(investor1);
        assertTrue(vault.whitelistedInvestors(investor1));
    }

    // ==================== FRACTIONALIZE ASSET TESTS ====================

    function test_AssetManager_CanFractionalizeAsset() public {
        vm.prank(assetManager);
        vm.expectEmit(true, false, false, true);
        emit AssetFractionalized(TOKEN_ID, ASSET_NAME, VALUATION, 550, SUPPLY);
        
        vault.fractionalizeAsset(TOKEN_ID, SUPPLY, ASSET_NAME, VALUATION);

        (string memory name, uint256 totalValuation, uint256 annualYieldRate, bool isPaused) 
            = vault.assets(TOKEN_ID);

        assertEq(name, ASSET_NAME);
        assertEq(totalValuation, VALUATION);
        assertEq(annualYieldRate, 550);
        assertFalse(isPaused);

        assertEq(vault.balanceOf(assetManager, TOKEN_ID), SUPPLY);
    }

    // ==================== TRANSFER TESTS ====================

    function test_Whitelisted_CanTransfer() public {
        // Asset erstellen
        vm.prank(assetManager);
        vault.fractionalizeAsset(TOKEN_ID, SUPPLY, ASSET_NAME, VALUATION);

        // WICHTIG: Beide Seiten müssen whitelisted sein
        vm.startPrank(securityOfficer);
        vault.addToWhitelist(assetManager);
        vault.addToWhitelist(investor1);
        vm.stopPrank();

        // Transfer durchführen
        vm.prank(assetManager);
        vault.safeTransferFrom(assetManager, investor1, TOKEN_ID, 100, "");

        assertEq(vault.balanceOf(investor1, TOKEN_ID), 100);
    }

    function test_NonWhitelisted_CannotTransfer() public {
        vm.prank(assetManager);
        vault.fractionalizeAsset(TOKEN_ID, SUPPLY, ASSET_NAME, VALUATION);

        vm.prank(assetManager);
        vm.expectRevert("Ines says: KYC/Whitelist check failed");
        vault.safeTransferFrom(assetManager, nonWhitelisted, TOKEN_ID, 100, "");
    }

    // ==================== INTERFACE TEST ====================

    function test_SupportsInterface() public view {
        assertTrue(vault.supportsInterface(0xd9b67a26)); // ERC1155
        assertTrue(vault.supportsInterface(0x01ffc9a7)); // ERC165
        assertTrue(vault.supportsInterface(0x7965db0b)); // AccessControl
    }
}