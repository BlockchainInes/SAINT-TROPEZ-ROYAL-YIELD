# 🏰 SAINT TROPEZ ROYAL YIELD VAULT

> **Repository:** `SAINT-TROPEZ-ROYAL-YIELD`

## 💎 Luxury Real Estate Fractionalization Protocol
**Tokenizing high-end properties in Saint-Tropez for fractional ownership.**

🌟 Overview
SAINT-TROPEZ-ROYAL-YIELD is a secure and compliant ERC-1155 smart contract engineered for the fractionalization of luxury real estate (Real World Assets - RWA).

The contract allows an Asset Manager to create digital tokens representing ownership shares in high-value properties, while a Security Officer manages investor whitelisting to ensure full regulatory compliance and KYC/AML standards.

🛠️ Core Features
Fractionalize Assets: Create ERC-1155 tokens representing shares of luxury property (fractionalizeAsset).


Role-Based Access Control:

👑 DEFAULT_ADMIN_ROLE: Full protocol oversight.

💼 ASSET_MANAGER_ROLE: Authorized to mint and manage fractional assets.

🛡️ SECURITY_OFFICER_ROLE: Manages investor whitelisting.

Strict Whitelist Enforcement: Only KYC-approved investors can receive or transfer tokens.

Asset Metadata: Stores property name, valuation, and a default annual yield rate (5.5%) on-chain.

Security Standards: Built with OpenZeppelin's ReentrancyGuard and AccessControl.


🧪 Proven Success (Testing)
I have developed and thoroughly tested the core features using Foundry with a 100% success rate.

7/7 Unit Tests Passed

✅ Deployment & Roles: Verified correct initialization.

✅ Whitelist Logic: Confirmed investor management functionality.

✅ Fractionalization: Tested minting and metadata storage.

✅ Restricted Transfers: Ensured only whitelisted addresses can trade.

✅ Security Barriers: Blocked unauthorized transfer attempts.

✅ ID Collision: Prevented duplicate asset creation.

✅ Standard Compliance: Fully supports ERC-1155 + ERC-165.

Command: forge test -vv


🚀 Current Status & Roadmap
Current Status

✅ Contract is fully functional and tested

✅ All unit tests passing

✅ Ready for testnet deployment


Future Improvements
I am actively expanding this project. Currently working on:

📈 Advanced Yield Distribution: More complex mechanisms for profit sharing.

⏸️ Asset Management: Pausing/unpausing specific asset IDs.

📜 Deployment Scripts: Full scripts for Sepolia and Ethereum Mainnet.

🧪 Advanced Testing: Implementing Fuzzing and Invariant tests.

🖥️ Frontend Dashboard: Building a UI with React + Wagmi + RainbowKit.

🤖 Automation: Automated yield calculation and claiming.

🔍 Audit Readiness: Preparing full documentation for security audits.


💻 Tech Stack
Language: Solidity ^0.8.20

Framework: Foundry (Forge)

Libraries: OpenZeppelin Contracts

Testing: Forge Std

📥 Quick Start
Bash

# 1. Install dependencies
forge install

# 2. Build the project
forge build

# 3. Run all tests
forge test -vv


### 🏗️ Protocol Architecture

```mermaid
graph TD
    Admin((👑 Admin)) -- "Grants Roles" --> Vault
    Manager((💼 Asset Manager)) -- "Mints Property Tokens" --> Vault
    Officer((🛡️ Security Officer)) -- "Whitelists Investors" --> Vault

    subgraph "Saint Tropez Royal Yield Vault (ERC-1155)"
        Vault{Smart Contract}
        Data[(On-Chain Metadata:<br/>Price, Yield 5.5%)]
        Rules{Compliance Logic}
    end

    InvestorA[👤 Investor A<br/>Whitelisted] -- "Can trade" --> Token((Token Share))
    InvestorB[👤 Investor B<br/>Whitelisted] -- "Can trade" --> Token
    NonAuth[❌ Unverified User] -- "BLOCKED" --> Token

    Vault --> Rules
    Rules --> Token
    Token --- Data
