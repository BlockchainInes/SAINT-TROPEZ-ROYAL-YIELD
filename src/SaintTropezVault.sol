// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SaintTropezVault is ERC1155, AccessControl, ReentrancyGuard {
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

    event AssetFractionalized(uint256 indexed id, string name, uint256 valuation, uint256 supply);
    event WhitelistUpdated(address indexed investor, bool status);
    event YieldDeposited(uint256 indexed id, uint256 amount);
    event YieldClaimed(address indexed investor, uint256 indexed id, uint256 amount);

    constructor() ERC1155("https://api.sainttropez.io/{id}.json") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SECURITY_OFFICER_ROLE, msg.sender);
        _grantRole(ASSET_MANAGER_ROLE, msg.sender);
    }

    function addToWhitelist(address investor) external onlyRole(SECURITY_OFFICER_ROLE) {
        whitelistedInvestors[investor] = true;
        emit WhitelistUpdated(investor, true);
    }

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

    function depositYield(uint256 id) external payable onlyRole(ASSET_MANAGER_ROLE) {
        require(assets[id].totalValuation > 0, "Asset not found");
        totalYieldPerAsset[id] += msg.value;
        emit YieldDeposited(id, msg.value);
    }

    function claimYield(uint256 id) external nonReentrant {
        require(whitelistedInvestors[msg.sender], "Not whitelisted");

        uint256 balance = balanceOf(msg.sender, id);
        require(balance > 0, "No tokens");

        uint256 totalSupply = assets[id].totalSupply;
        require(totalSupply > 0, "Asset not found");

        uint256 totalShare = (totalYieldPerAsset[id] * balance) / totalSupply;
        uint256 withdrawable = totalShare - claimedYield[msg.sender][id];

        require(withdrawable > 0, "Nothing to claim");

        claimedYield[msg.sender][id] += withdrawable;

        (bool success, ) = payable(msg.sender).call{value: withdrawable}("");
        require(success, "Transfer failed");

        emit YieldClaimed(msg.sender, id, withdrawable);
    }

    // === supportsInterface FIX ===
       function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            whitelistedInvestors[msg.sender] || hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "KYC needed"
        );
        super.safeTransferFrom(from, to, id, amount, data);
    }
}