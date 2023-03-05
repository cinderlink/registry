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

        // address user = vm.envAddress("USER_ADDRESS");
        // token.mint(user, 10000000000000000000000);

        address usersAddress = vm.envAddress("REGISTRY_USERS_ADDRESS");
        UserRegistry users = UserRegistry(usersAddress);


        address permissionsAddress = vm.envAddress("REGISTRY_PERMISSIONS_ADDRESS");
        PermissionRegistry permissions = PermissionRegistry(permissionsAddress);

        address attestor = vm.envAddress("ATTESTOR_ADDRESS");
        token.mint(attestor, 10000000000000000000000);
        users.register("Cinderlink Attestor", "did:cndr:attestor", attestor);

        permissions.grantPermission(attestor, "airdrop.grant");

        vm.stopBroadcast();
    }
}
