// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// Integration of Chainlink Automation for trustless, decentralized yield distribution
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

/**
 * @title SaintTropezVault
 * @author Ines
 * @notice Real Estate Fractionalization Vault with Automated Yield Management.
 * @dev This contract handles RWA (Real World Asset) tokenization and utilizes 
 * Chainlink Keepers to automate rental income distribution to shareholders.
 */
contract SaintTropezVault is ERC1155, AccessControl, ReentrancyGuard, AutomationCompatibleInterface {
    bytes32 public constant SECURITY_OFFICER_ROLE = keccak256("SECURITY_OFFICER_ROLE");
    bytes32 public constant ASSET_MANAGER_ROLE = keccak256("ASSET_MANAGER_ROLE");

    struct Asset {
        string name;
        uint256 totalValuation;
        uint256 totalSupply;
        bool isPaused;
    }

    mapping(uint256 => Asset) public assets;
    mapping(address => bool) public whitelistedInvestors;
    mapping(uint256 => uint256) public totalYieldPerAsset;
    mapping(address => mapping(uint256 => uint256)) public claimedYield;
    
    // Internal registry for automation logic to iterate over active investors
    address[] public investorList; 

    event AssetFractionalized(uint256 indexed id, string name, uint256 valuation, uint256 supply);
    event WhitelistUpdated(address indexed investor, bool status);
    event YieldDeposited(uint256 indexed id, uint256 amount);
    event YieldClaimed(address indexed investor, uint256 indexed id, uint256 amount);

    constructor() ERC1155("https://api.sainttropez.io/{id}.json") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SECURITY_OFFICER_ROLE, msg.sender);
        _grantRole(ASSET_MANAGER_ROLE, msg.sender);
    }

    /**
     * @dev Internal helper: Tracks investors to enable the push-based automated payment model.
     */
    function _addToInvestorList(address investor) internal {
        for (uint i = 0; i < investorList.length; i++) {
            if (investorList[i] == investor) return;
        }
        investorList.push(investor);
    }

    /**
     * @dev Compliance/KYC: Only whitelisted addresses can hold or transfer property shares.
     */
    function addToWhitelist(address investor) external onlyRole(SECURITY_OFFICER_ROLE) {
        whitelistedInvestors[investor] = true;
        _addToInvestorList(investor);
        emit WhitelistUpdated(investor, true);
    }

    /**
     * @dev Fractionalization: Mints digital shares representing a percentage of a physical asset.
     */
    function fractionalizeAsset(
        uint256 id,
        uint256 supply,
        string memory name,
        uint256 valuation
    ) external onlyRole(ASSET_MANAGER_ROLE) {
        require(assets[id].totalValuation == 0, "Asset already exists");

        assets[id] = Asset({
            name: name,
            totalValuation: valuation,
            totalSupply: supply,
            isPaused: false
        });

        _mint(msg.sender, id, supply, "");
        emit AssetFractionalized(id, name, valuation, supply);
    }

    /**
     * @dev Yield Ingestion: Receives rental income in ETH to be distributed proportionally.
     */
    function depositYield(uint256 id) external payable onlyRole(ASSET_MANAGER_ROLE) {
        require(assets[id].totalValuation > 0, "Asset not found");
        totalYieldPerAsset[id] += msg.value;
        emit YieldDeposited(id, msg.value);
    }

    // --- Chainlink Automation Core (Keeper Logic) ---

    /**
     * @dev checkUpkeep: Off-chain check to identify if an asset has pending yield for distribution.
     * @param checkData Encoded Asset ID to monitor.
     */
    function checkUpkeep(bytes calldata checkData) 
        external 
        view 
        override 
        returns (bool upkeepNeeded, bytes memory performData) 
    {
        uint256 targetAssetId = abi.decode(checkData, (uint256));
        // Automation triggers if undistributed yield is present
        if (totalYieldPerAsset[targetAssetId] > 0) {
            upkeepNeeded = true;
            performData = checkData;
        }
    }

    /**
     * @dev performUpkeep: Triggered on-chain to execute the automated distribution logic.
     * Implements a push-based reward system for verified investors.
     */
    function performUpkeep(bytes calldata performData) external override {
        uint256 id = abi.decode(performData, (uint256));
        uint256 totalSupply = assets[id].totalSupply;
        require(totalSupply > 0, "Execution Error: Invalid asset ID");

        for (uint256 i = 0; i < investorList.length; i++) {
            address investor = investorList[i];
            
            if (whitelistedInvestors[investor]) {
                uint256 balance = balanceOf(investor, id);
                if (balance > 0) {
                    uint256 totalShare = (totalYieldPerAsset[id] * balance) / totalSupply;
                    uint256 withdrawable = totalShare - claimedYield[investor][id];

                    if (withdrawable > 0) {
                        claimedYield[investor][id] += withdrawable;
                        (bool success, ) = payable(investor).call{value: withdrawable}("");
                        if (success) {
                            emit YieldClaimed(investor, id, withdrawable);
                        }
                    }
                }
            }
        }
    }

    /**
     * @dev Compliance override: Enforces whitelisting for all peer-to-peer transfers.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            whitelistedInvestors[msg.sender] || hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Security Policy: Only whitelisted addresses may execute transfers"
        );
        super.safeTransferFrom(from, to, id, amount, data);
    }

    // Required overrides for AccessControl & ERC1155
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}