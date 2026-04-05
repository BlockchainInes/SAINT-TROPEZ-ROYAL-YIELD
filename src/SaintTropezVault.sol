// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SaintTropezVault
 * @dev Protocol for luxury real estate fractionalization - Project by Inés
 * Features: Role-based access control, investor whitelisting, and granular asset pausing.
 */
contract SaintTropezVault is ERC1155, AccessControl, ReentrancyGuard {

    // Roles definition using Keccak256 hashes
    bytes32 public constant SECURITY_OFFICER_ROLE = keccak256("SECURITY_OFFICER_ROLE");
    bytes32 public constant ASSET_MANAGER_ROLE = keccak256("ASSET_MANAGER_ROLE");

    struct Asset {
        string name;
        uint256 totalValuation;
        uint256 annualYieldRate; // e.g., 550 for 5.50%
        bool isPaused;
    }

    // Mappings for asset data and compliance whitelisting
    mapping(uint256 => Asset) public assets;
    mapping(address => bool) public whitelistedInvestors;

    // ==================== EVENTS ====================

    event AssetFractionalized(
        uint256 indexed id, 
        string name, 
        uint256 valuation, 
        uint256 yieldRate, 
        uint256 supply
    );
    
    event WhitelistUpdated(address indexed investor, bool status);

    // Event triggered when an asset's pause status is toggled
    event AssetPauseStatusChanged(uint256 indexed id, bool paused);

    constructor() 
        ERC1155("https://api.sainttropez-yield.io/metadata/{id}.json") 
    {
        // Granting all initial roles to the deployer (Inés)
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SECURITY_OFFICER_ROLE, msg.sender);
        _grantRole(ASSET_MANAGER_ROLE, msg.sender);
    }

    // ==================== MODIFIERS ====================

    /**
     * @dev Restricts access to whitelisted investors only
     */
    modifier onlyWhitelisted() {
        require(whitelistedInvestors[msg.sender], "Ines says: KYC/Whitelist check failed");
        _;
    }

    // ==================== WHITELIST FUNCTIONS ====================

    /**
     * @dev Security Officer adds an investor to the whitelist
     */
    function addToWhitelist(address investor) 
        external 
        onlyRole(SECURITY_OFFICER_ROLE) 
    {
        whitelistedInvestors[investor] = true;
        emit WhitelistUpdated(investor, true);
    }

    /**
     * @dev Security Officer removes an investor from the whitelist
     */
    function removeFromWhitelist(address investor) 
        external 
        onlyRole(SECURITY_OFFICER_ROLE) 
    {
        whitelistedInvestors[investor] = false;
        emit WhitelistUpdated(investor, false);
    }

    // ==================== ASSET FUNCTIONS ====================

    /**
     * @dev Asset Manager mints property tokens and defines asset metadata
     */
    function fractionalizeAsset(
        uint256 id,
        uint256 supply,
        string memory name,
        uint256 valuation
    ) external onlyRole(ASSET_MANAGER_ROLE) {
        require(assets[id].totalValuation == 0, "Asset with this ID already exists");
        
        assets[id] = Asset({
            name: name,
            totalValuation: valuation,
            annualYieldRate: 550,     // 5.5% Default yield
            isPaused: false
        });

        _mint(msg.sender, id, supply, "");

        emit AssetFractionalized(id, name, valuation, 550, supply);
    }

    /**
     * @dev Allows the Asset Manager to pause/unpause trading for a specific asset ID.
     * Essential for legal updates or property maintenance periods.
     */
    function setAssetPauseStatus(uint256 id, bool pauseStatus) 
        external 
        onlyRole(ASSET_MANAGER_ROLE) 
    {
        require(assets[id].totalValuation > 0, "Ines says: Asset does not exist");
        
        assets[id].isPaused = pauseStatus;
        
        emit AssetPauseStatusChanged(id, pauseStatus);
    }

    // ==================== OVERRIDES ====================

    /**
     * @dev Required override to resolve conflicts between ERC1155 and AccessControl
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Overrides safeTransferFrom to enforce both Whitelist and Asset Pause checks
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) 
        public 
        virtual 
        override 
        onlyWhitelisted 
    {
        require(!assets[id].isPaused, "Ines says: This specific asset is currently paused");
        super.safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev Overrides safeBatchTransferFrom to enforce checks for all assets in the batch
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) 
        public 
        virtual 
        override 
        onlyWhitelisted 
    {
        for (uint256 i = 0; i < ids.length; i++) {
            require(!assets[ids[i]].isPaused, "Ines says: One or more assets in this batch are paused");
        }
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}