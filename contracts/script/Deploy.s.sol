// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Token/CinderToken.sol";
import "../src/Registry/UserRegistry.sol";
import "../src/Registry/PermissionRegistry.sol";
import "../src/Registry/SchemaRegistry.sol";
import "../src/Registry/EntityTypeRegistry.sol";
import "../src/Registry/EntityRegistry.sol";
import "../src/Registry/EntityDefinitionRegistry.sol";
import "../src/DAO/CinderStaking.sol";
import "../src/DAO/CinderDAO.sol";
import "../src/Optimism/AttestationStation.sol";
import "../src/Optimism/AttestationProxy.sol";
import "../src/Token/CinderAirdrop.sol";

contract DeployScript is Script {
    CinderToken token;
        UserRegistry users;
        PermissionRegistry permissions;
        CinderStaking staking;
        SchemaRegistry schemas;
        EntityTypeRegistry entityTypes;
        EntityRegistry entities;
        EntityDefinitionRegistry definitions;
        AttestationStation attestations;
        AttestationProxy proxy;
        CinderAirdrop airdrop;
        CinderDAO dao;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        token = new CinderToken();
        users = new UserRegistry();
        permissions = new PermissionRegistry(address(users));
        staking = new CinderStaking(address(token), address(permissions));
        schemas = new SchemaRegistry("cndr.reg", address(permissions));
        entityTypes = new EntityTypeRegistry("cndr.reg", address(permissions));
        entities = new EntityRegistry("cndr.reg", address(permissions), address(entityTypes));
        definitions =
            new EntityDefinitionRegistry("cndr.reg", address(permissions), address(entities), address(schemas));
        attestations = new AttestationStation();
        proxy = new AttestationProxy(address(attestations), address(permissions));
        airdrop = new CinderAirdrop(address(token), address(proxy), address(permissions));

        // address deployer = vm.envAddress("DEPLOYER_ADDRESS");
        // token.mint(deployer, 10000000000000000000000);

        // token.mint(user, 10000000000000000000000);

        // token.mint(attestor, 10000000000000000000000);
        token.mint(address(airdrop), 10000000000000000000000);

        deployDAO();

        registerStaking();
        registerAttestor();
        registerUser();
    }

    function registerStaking() public {
        uint256 stakingUserId = users.register("staking", "did:cndr:staking", address(staking));
        permissions.registerPermission("cndr.create", "cid", stakingUserId);
        permissions.registerPermission("cndr.moderate", "cid", stakingUserId);
    }

    function registerAttestor() public {
        address attestor = vm.envAddress("ATTESTOR_ADDRESS");
        uint256 attestorPrivateKey = vm.envUint("ATTESTOR_PRIVATE_KEY");
        vm.stopBroadcast();
        vm.startBroadcast(attestorPrivateKey);
        users.register("attestor", "did:cndr:attestor", attestor);
        permissions.registerPermission("airdrop.grant", "cid");
        permissions.registerPermission("airdrop.claim", "cid");
        permissions.registerPermission("airdrop.attest", "cid");
    }

    function deployDAO() public {
        users.register("cndr.deployer", "deployer.cid");
        uint256 proposalSchemaId = schemas.register("cndr.proposal", "test.proposal");
        uint256 voteSchemaId = schemas.register("cndr.vote", "test.vote");
        uint256 commentSchemaId = schemas.register("cndr.comment", "test.comment");

        dao = new CinderDAO(
            "cndr.dao",
            address(staking),
            address(token),
            address(permissions),
            address(entities),
            address(definitions),
            proposalSchemaId,
            voteSchemaId,
            commentSchemaId
        );
    }
    
    function registerUser() public {
        address user = vm.envAddress("USER_ADDRESS");
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("USER_PRIVATE_KEY"));
        users.register("test", "did:cndr:testUser", user);
    }
}
