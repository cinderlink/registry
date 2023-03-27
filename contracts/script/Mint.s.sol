// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Token/CinderToken.sol";
import "../src/Registry/UserRegistry.sol";
import "../src/Registry/PermissionRegistry.sol";

contract MintScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        CinderToken token = CinderToken(tokenAddress);

        // address deployer = vm.envAddress("DEPLOYER_ADDRESS");
        // token.mint(deployer, 10000000000000000000000);

        address user = vm.envAddress("USER_ADDRESS");
        // token.mint(user, 10000000000000000000000);

        address usersAddress = vm.envAddress("REGISTRY_USERS_ADDRESS");
        UserRegistry users = UserRegistry(usersAddress);

        address permissionsAddress = vm.envAddress("REGISTRY_PERMISSIONS_ADDRESS");
        PermissionRegistry permissions = PermissionRegistry(permissionsAddress);

        address attestor = vm.envAddress("ATTESTOR_ADDRESS");
        // token.mint(attestor, 10000000000000000000000);
        token.mint(vm.envAddress("AIRDROP_ADDRESS"), 10000000000000000000000);

        uint256 stakingUserId = users.register("staking", "did:cndr:staking", vm.envAddress("STAKING_ADDRESS"));
        permissions.registerPermission("cndr.create", "cid", stakingUserId);
        permissions.registerPermission("cndr.moderate", "cid", stakingUserId);
        vm.stopBroadcast();

        vm.startBroadcast(vm.envUint("USER_PRIVATE_KEY"));
        users.register("test", "did:cndr:testUser", user);
        vm.stopBroadcast();

        uint256 attestorPrivateKey = vm.envUint("ATTESTOR_PRIVATE_KEY");
        vm.startBroadcast(attestorPrivateKey);
        users.register("attestor", "did:cndr:attestor", attestor);
        permissions.registerPermission("airdrop.grant", "cid");
        permissions.registerPermission("airdrop.claim", "cid");
        permissions.registerPermission("airdrop.attest", "cid");
    }
}
