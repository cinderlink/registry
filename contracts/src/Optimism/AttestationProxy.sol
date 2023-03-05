// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Copied from FlipsideCrypto's
// https://github.com/FlipsideCrypto/user_metrics/blob/main/apps/optimism/attestation_contracts/contracts/FlipsideAttestation.sol
// with small changes.

import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { PermissionedContract } from "../Registry/PermissionedContract.sol";


interface IAttestationStation {
    struct AttestationData {
        address about;
        bytes32 key;
        bytes val;
    }

    event AttestationCreated(
        address indexed creator,
        address indexed about,
        bytes32 indexed key,
        bytes val
    );

    function attest(AttestationData[] memory _attestations) external;
}

contract AttestationProxy is PermissionedContract {
    using ECDSA for bytes32;

    /// @dev The interface for OP's Attestation Station.
    IAttestationStation public attestationStation;
    mapping(address => int256) public trust;
    mapping(address => mapping(address => uint256)) public attestedAmount;

    uint256 constant MIN_ATTEST_TRUST = 100;

    constructor(
        address _attestationAddress,
        address _permissionsAddress
    ) PermissionedContract(msg.sender, "airdrop", _permissionsAddress) {
        attestationStation = IAttestationStation(_attestationAddress);
    }

    /**
     * @notice Allows the owner to change the AttestationStation implementation.
     * @param _attestationStation The address of the new AttestationStation implementation.
     * 
     * Requirements:
     * - The caller must be the current owner.
     */
    function setAttestationStation(address _attestationStation) public {
        require(owner == msg.sender, "AttestationProxy: caller is not the owner");
        attestationStation = IAttestationStation(_attestationStation);
    }

    function attested(
        address _about,
        address _attester
    ) public view returns (uint256) {
        return attestedAmount[_about][_attester];
    }

    function attest(address _about, bytes32 _key, bytes memory _val) public {
        int256 _trustValue = abi.decode(_val, (int256));
        require(
            // user can't attest greater than their own trust for an address
            (
                owner == msg.sender ||
                userHasPermission("attest", msg.sender) || 
                (
                    int256(attested(_about, msg.sender)) + _trustValue <= trust[msg.sender] && 
                    int256(attested(_about, msg.sender)) - _trustValue >= (trust[msg.sender] * -1)
                )
            ),
            "AttestationProxy: Attestation limit reached for this address"
        );
        trust[_about] += _trustValue;

        // Send the attestation to the Attestation Station.
        IAttestationStation.AttestationData[] memory attestations = new IAttestationStation.AttestationData[](1);
        attestations[0] = IAttestationStation.AttestationData({
              about: _about
            , key: _key
            , val: _val
        });
        attestationStation.attest(attestations);
    }
}