// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import "../Registry/UserRegistry.sol";
import "../Registry/PermissionRegistry.sol";
import "../Token/CinderToken.sol";
import "../Token/CinderAirdrop.sol";
import "./AttestationProxy.sol";
import "./AttestationStation.sol";

contract CinderDAOTest is Test {
    AttestationStation station;
    AttestationProxy proxy;
    UserRegistry users;
    PermissionRegistry permissions;
    CinderToken token;
    CinderAirdrop airdrop;

    address deployer;
    address attestor;
    address attestee;

    function setUp() public {
        deployer = vm.addr(1);
        attestee = vm.addr(2);
        attestor = vm.addr(9);
        vm.startPrank(deployer);

        token = new CinderToken();
        users = new UserRegistry();
        permissions = new PermissionRegistry(address(users));
        station = new AttestationStation();
        proxy = new AttestationProxy(address(station), address(permissions));
        airdrop = new CinderAirdrop(address(token), address(proxy), address(permissions));
    }

    function testCreateAttestation() public {
        token.mint(attestor, 1000000000);
        uint attestorId = users.register("attestor", "did:attestor", address(attestor));
        uint permId = permissions.registerPermission("attest", "cid", 0, attestor);
        permissions.grantPermission(attestorId, permId);

        bytes32 key = bytes32("test.attestation");
        vm.stopPrank();

        vm.startPrank(attestor);
        proxy.attest(
            attestee,
            key,
            1
        );

        int attested = proxy.attested(attestee, attestor);
        require(attested == 1, "Attestation value mismatch");
    }
}