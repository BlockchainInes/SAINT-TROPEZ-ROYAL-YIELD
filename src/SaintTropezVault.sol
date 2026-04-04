// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SaintTropezRoyalYield
 * @dev Protokoll zur Fraktionierung von Luxusimmobilien - Projekt für Inés
 */
contract SaintTropezVault is ERC1155, AccessControl, ReentrancyGuard {

    bytes32 public constant SECURITY_OFFICER_ROLE = keccak256("SECURITY_OFFICER_ROLE");
    bytes32 public constant ASSET_MANAGER_ROLE = keccak256("ASSET_MANAGER_ROLE");

    struct Asset {
        string name;
        uint256 totalValuation;
        uint256 annualYieldRate; // z.B. 550 für 5.50%
        bool isPaused;
    }

    mapping(uint256 => Asset) public assets;
    mapping(address => bool) public whitelistedInvestors;

    // Events
    event AssetFractionalized(
        uint256 indexed id, 
        string name, 
        uint256 valuation, 
        uint256 yieldRate, 
        uint256 supply
    );
    
    event WhitelistUpdated(address indexed investor, bool status);

    constructor() 
        ERC1155("https://api.sainttropez-yield.io/metadata/{id}.json") 
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SECURITY_OFFICER_ROLE, msg.sender);
        _grantRole(ASSET_MANAGER_ROLE, msg.sender);
    }

    // ==================== MODIFIERS ====================

    modifier onlyWhitelisted() {
        require(whitelistedInvestors[msg.sender], "Ines says: KYC/Whitelist check failed");
        _;
    }

    // ==================== WHITELIST FUNCTIONS ====================

    function addToWhitelist(address investor) 
        external 
        onlyRole(SECURITY_OFFICER_ROLE) 
    {
        whitelistedInvestors[investor] = true;
        emit WhitelistUpdated(investor, true);
    }

    function removeFromWhitelist(address investor) 
        external 
        onlyRole(SECURITY_OFFICER_ROLE) 
    {
        whitelistedInvestors[investor] = false;
        emit WhitelistUpdated(investor, false);
    }

    // ==================== ASSET FUNCTIONS ====================

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
            annualYieldRate: 550,     // 5.5% Standard-Rendite
            isPaused: false
        });

        _mint(msg.sender, id, supply, "");

        emit AssetFractionalized(id, name, valuation, 550, supply);
    }

    // ==================== OVERRIDES ====================

    /**
     * @dev Wichtig: Löst den Konflikt zwischen ERC1155 und AccessControl
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
     * @dev Überschreibt safeTransferFrom und erzwingt Whitelist-Check
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
        require(!assets[id].isPaused, "This asset is currently paused");
        super.safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev Optional: Auch Batch-Transfers auf Whitelist beschränken
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
            require(!assets[ids[i]].isPaused, "One or more assets are paused");
        }
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }
}