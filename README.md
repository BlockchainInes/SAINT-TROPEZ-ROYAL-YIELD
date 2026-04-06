# 🏰 SAINT TROPEZ ROYAL YIELD

**Repository:** `SAINT-TROPEZ-ROYAL-YIELD`  
**Concept:** 💎 Luxury Real Estate Fractionalization Protocol

## 🌟 Overview
**SAINT-TROPEZ-ROYAL-YIELD** is a secure, compliant, and rigorously tested smart contract architecture designed for the fractionalization of high-end luxury real estate (Real World Assets - RWA). 

Built on the **ERC-1155** standard, the protocol allows an Asset Manager to mint digital shares representing ownership in premium properties, while a dedicated Security Officer ensures that only KYC-verified and whitelisted investors can participate in the ecosystem.

---

## 🏗️ Architecture & Protocol Flow

```mermaid
graph TD
    subgraph Roles
        A[Admin] -- Grant Roles --> AM[Asset Manager]
        A -- Grant Roles --> SO[Security Officer]
    end

    subgraph Actions
        AM -- Fractionalize Property --> V[Saint Tropez Vault]
        AM -- Deposit ETH Yield --> V
        SO -- KYC Whitelist --> I[Investor]
    end

    subgraph "Yield Flow"
        I -- Holds ERC-1155 Tokens --> V
        I -- claimYield --> V
        V -- Proportional ETH --> I
    end

    style V fill:#f9f,stroke:#333,stroke-width:4px
    style I fill:#bbf,stroke:#333,stroke-width:2px

    🛠️ Core Features
Fractionalized Ownership: High-value assets are divided into affordable on-chain tokens.

Role-Based Access Control (RBAC):

👑 DEFAULT_ADMIN_ROLE: Full protocol oversight.

💼 ASSET_MANAGER_ROLE: Manages asset minting, valuations, and yield deposits.

🛡️ SECURITY_OFFICER_ROLE: Handles investor whitelisting (KYC/AML).

Compliance Layer: Built-in whitelist enforcement for all token transfers.

Automated Yield Distribution: Proportional ETH-based profit sharing based on token holdings.

Granular Security: Ability to pause/manage specific asset IDs without affecting the entire vault.

🧪 Advanced Testing & Quality Assurance
The protocol's integrity is verified using the Foundry (Forge) framework. I have implemented a multi-layered testing strategy to ensure economic and technical security.

📊 Testing Methodologies
Unit Testing: 100% coverage of core functions like minting, whitelisting, and role assignments.

Access Control (Revert Tests): Verified that unauthorized users are strictly blocked from sensitive administrative functions.

Fuzz Testing: Property-based testing used to verify the claimYield logic across 256+ random scenarios (varying ETH deposits and token supplies) to ensure mathematical proportionality.

Invariant Testing: Mathematical proof that the Total Claimed Yield can never exceed the Total Deposited Yield for any given asset.

Boundary Testing: Confirmed precision and stability with high token supplies (up to 1,000,000 shares per property).

🚀 Run Tests
To verify the robustness locally, ensure you have Foundry installed and run:

Bash
# Build the project
forge build

# Run all tests (including Fuzzing)
forge test -vv

# Generate coverage report
forge coverage
💻 Tech Stack
Language: Solidity ^0.8.20

Framework: Foundry (Forge)

Library: OpenZeppelin (AccessControl, ReentrancyGuard, ERC1155)

Environment: Designed for Ethereum / Layer 2 (Sepolia Testnet ready)

🚀 Roadmap & Progress
[x] Core Protocol Development: ERC-1155 implementation and role management.

[x] Whitelisting System: Secure KYC-based transfer logic.

[x] Advanced Yield Logic: ETH-based distribution and claiming system.

[x] Advanced Testing: Implementation of Fuzzing and Invariant tests.

[ ] Deployment Scripts: Full scripts for Sepolia and Ethereum Mainnet.

[ ] Automation: Integrating Chainlink Keepers for automated yield triggers.

[ ] Frontend Dashboard: UI build with React + Wagmi + RainbowKit.

Author: Ines Krüger

Smart Contract Developer & Blockchain Architect
