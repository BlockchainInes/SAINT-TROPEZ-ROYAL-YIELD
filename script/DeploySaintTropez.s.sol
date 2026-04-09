// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/SaintTropezVault.sol";

contract DeploySaintTropez is Script {
    function run() external {
        // Retrieve private key from .env file
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions to the RPC endpoint
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the contract
        SaintTropezVault vault = new SaintTropezVault();

        // Optional: Pre-configuration (e.g., fractionalizing the first asset)
        // vault.fractionalizeAsset(1, 1000, "Villa Royale", 10_000_000);

        vm.stopBroadcast();

        // Log the address to the console
        console.log("Saint Tropez Vault deployed at:", address(vault));
    }
}