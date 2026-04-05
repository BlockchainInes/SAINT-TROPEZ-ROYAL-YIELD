# Saint Tropez Royal Yield – Fractional Real Estate Yield Vault

A secure, fractional ownership protocol for real-world assets (RWAs) built on Ethereum. Users can own fractions of luxury assets (e.g., villas in Saint-Tropez) as ERC-1155 tokens and automatically earn proportional yield from rental income or other revenue streams.

## ✨ Features

- **Fractional Ownership**: Mint ERC-1155 tokens representing shares of high-value real estate assets.
- **Yield Distribution**: Deposit yield (rental income, etc.) and let holders claim their proportional share.
- **Granular Asset Management**: Pause/unpause individual assets for maintenance or legal reasons.
- **Whitelist & KYC Protection**: Only verified investors can hold and transfer tokens.
- **Role-Based Access Control**: Separate roles for Security Officer and Asset Manager.
- **Reentrancy Protection**: Built with OpenZeppelin's `ReentrancyGuard`.
- **Tested with Foundry**: Comprehensive unit tests (more advanced tests coming soon).

## 📋 Current Status

| Feature                        | Status     | Description |
|--------------------------------|------------|-----------|
| Asset Management & Pausing     | ✅ Done    | Granular pause/unpause per asset ID |
| Basic Yield Distribution       | ✅ Done    | Proportional yield claiming |
| Whitelist + Access Control     | ✅ Done    | KYC-gated transfers |
| Advanced Yield Mechanisms      | 📈 In Progress | Automated profit sharing (in development) |
| Deployment Scripts             | Planned    | Sepolia + Ethereum Mainnet |
| Advanced Testing               | Planned    | Fuzzing & Invariant tests |
| Frontend Dashboard             | Planned    | React + Wagmi + RainbowKit |
| Automation                     | Planned    | Chainlink Keepers for auto-claiming |
| Audit Readiness                | In Progress| Full NatSpec documentation & risk analysis |

## 🛠️ Tech Stack

- **Smart Contracts**: Solidity ^0.8.20
- **Standards**: ERC-1155, AccessControl, ReentrancyGuard
- **Development**: Foundry
- **Libraries**: OpenZeppelin Contracts

## 🚀 Quick Start

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed

### Clone & Install
```bash
git clone <your-repo-url>
cd Saint-Tropez-Royal-Yield
forge install
Run Tests
Bashforge clean
forge test -vv
Format & Coverage
Bashforge fmt
forge coverage --report summary
📁 Project Structure
text├── src/
│   └── SaintTropezVault.sol          # Main vault contract
├── test/
│   └── SaintTropezVault.t.sol        # Unit tests
├── script/
│   └── Deploy.s.sol                  # (coming soon)
├── lib/
└── foundry.toml
🔐 Security Considerations

All sensitive functions are protected by role-based access control.
Token transfers are restricted to whitelisted addresses.
Yield claiming uses nonReentrant guard.
The contract is designed with audit readiness in mind (full NatSpec documentation in progress).

Note: This is an actively developed protocol. Do not use in production before a professional security audit.
📄 License
MIT License – see LICENSE file.
🤝 Contributing
Contributions, issues, and feature requests are welcome!
Feel free to open a Pull Request or create an Issue.

Built with ❤️ for fractional real estate ownership and transparent yield distribution.
text









# 🏰 SAINT TROPEZ ROYAL YIELD VAULT

> **Repository:** `SAINT-TROPEZ-ROYAL-YIELD`

## 💎 Luxury Real Estate Fractionalization Protocol
**Tokenizing high-end properties in Saint-Tropez for fractional ownership.**


🌟 Overview

SAINT-TROPEZ-ROYAL-YIELD is a secure and compliant ERC-1155 smart contract engineered for the fractionalization of luxury real estate (Real World Assets - RWA).

The contract allows an Asset Manager to create digital tokens representing ownership shares in high-value properties, while a Security Officer manages investor whitelisting to ensure full regulatory compliance and KYC/AML standards.:



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




## 🚀 Roadmap & Progress

I am actively developing this protocol. Here is the current status of the planned improvements:

* ✅ **Asset Management**: [DONE] Implemented granular pausing/unpausing for specific asset IDs to handle maintenance or legal updates.
* 📈 **Advanced Yield Distribution**: [In Progress] Developing complex mechanisms for automated profit sharing.
* 📜 **Deployment Scripts**: Planned full scripts for Sepolia and Ethereum Mainnet.
* 🧪 **Advanced Testing**: Planned integration of Fuzzing and Invariant tests.
* 🖥️ **Frontend Dashboard**: Planned UI build with React + Wagmi + RainbowKit.
* 🤖 **Automation**: Planned automated yield calculation and claiming via Chainlink Keepers.
* 🔍 **Audit Readiness**: Preparing full documentation for security audits.

---

## 🛠 Technical Features (Updated)

* **Fractionalization**: Divide high-value assets into ERC1155 tokens.
* **Access Control**: Different levels of permissions (Admin, Security Officer, Asset Manager).
* **Compliance**: Built-in whitelist system for KYC-verified investors.
* **Granular Security**: Ability to pause trading for individual assets without affecting the entire vault.

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
