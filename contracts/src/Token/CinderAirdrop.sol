// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./CinderToken.sol";
import "../Optimism/AttestationProxy.sol";
import "../Registry/PermissionedContract.sol";

contract CinderAirdrop is PermissionedContract {
    CinderToken public cinderToken;
    AttestationProxy public attestation;

    uint256 constant GRANT_MAX = 1000000000000;
    uint256 constant TRUST_MULTI = 1000;
    uint256 grantedAmount = 0;
    uint256 minimumTrust = 100;

    struct AirdropUser {
        address user;
        uint256 unclaimed;
        uint256 trustClaim;
        uint256 lastGrantedAt;
        uint256 lastClaimedAt;
    }

    mapping(address => AirdropUser) public claimants;

    constructor(address _cinderToken, address _attestationProxy, address _permissionsAddress) PermissionedContract(msg.sender, "airdrop", _permissionsAddress) {
        cinderToken = CinderToken(_cinderToken);
        attestation = AttestationProxy(_attestationProxy);
    }

    function grant(address[] memory _addresses, uint256[] memory _amounts) public {
        requirePermission("grant");
        require(_addresses.length == _amounts.length, "Invalid input");
        require(_addresses.length > 0, "Nobody to grant to");
        for (uint256 i = 0; i < _addresses.length; i++) {
            require(_amounts[i] > 0, "Invalid amount");
            require(grantedAmount + _amounts[i] <= GRANT_MAX, "Grant limit reached");
            grantedAmount += _amounts[i];
            claimants[_addresses[i]].unclaimed += _amounts[i];
            claimants[_addresses[i]].lastGrantedAt = block.timestamp;
        }
    }

    function claim() public {
        requirePermission("claim");
        require(claimants[msg.sender].unclaimed > 0, "Nothing to claim");
        int256 _trust = attestation.trust(msg.sender);
        require(attestation.trust(msg.sender) > int256(minimumTrust), "Not enough trust");
        if (int256(claimants[msg.sender].trustClaim) < _trust) {
            claimants[msg.sender].unclaimed += uint256(_trust - int256(claimants[msg.sender].trustClaim)) * TRUST_MULTI;
            claimants[msg.sender].trustClaim = uint256(_trust);
        }
        cinderToken.transfer(msg.sender, claimants[msg.sender].unclaimed);
        claimants[msg.sender].unclaimed = 0;
        claimants[msg.sender].lastClaimedAt = block.timestamp;
    }

    function unclaimed() public view returns (uint256) {
        return claimants[msg.sender].unclaimed;
    }
}