// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../src/SaintTropezVault.sol";

contract SaintTropezVaultTest is Test, IERC1155Receiver {
    SaintTropezVault public vault;
    address public admin = address(this);
    address public user = address(0xABC);

    function setUp() public {
        vault = new SaintTropezVault();
        vault.addToWhitelist(admin);
        vault.addToWhitelist(user);
        vm.deal(admin, 10 ether);
    }

    // === ERC1155 Receiver Hooks ===
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }

    // === WICHTIG: supportsInterface implementieren (fehlte bisher) ===
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }

    // === DEINE TESTS ===
    function test_FractionalizeAndDepositYield() public {
        vault.fractionalizeAsset(1, 1000, "Villa", 1000000);
        vault.depositYield{value: 1 ether}(1);
        assertEq(vault.totalYieldPerAsset(1), 1 ether);
    }

    function test_ClaimYield() public {
        vault.fractionalizeAsset(1, 1000, "Villa", 1000000);
        
        vault.safeTransferFrom(admin, user, 1, 100, "");
        
        vault.depositYield{value: 1 ether}(1);

        vm.startPrank(user);
        uint256 balanceBefore = user.balance;
        vault.claimYield(1);
        uint256 balanceAfter = user.balance;
        vm.stopPrank();

        assertEq(balanceAfter - balanceBefore, 0.1 ether);
    }
}