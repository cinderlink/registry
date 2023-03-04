import { ethers } from 'ethers';
import { AttestationStation } from '$lib/contracts/AttestationStation';

export interface AttestationOption {
	key: string;
	label: string;
	value?: number;
	valueFn?: () => number;
}

export function attest(signer: ethers.Signer, attestations: AttestationOption[]) {
	const contract = new ethers.Contract(AttestationStation.address, AttestationStation.abi, signer);

	return contract.attest(attestations);
}

export function getUserAttestations(address: string, provider: ethers.providers.Provider) {
	const contract = new ethers.Contract(
		AttestationStation.address,
		AttestationStation.abi,
		provider
	);
	return contract.getUserAttestations(address);
}

export function calculateAttestationSum(
	logs: ethers.providers.Log[],
	config: { include?: string[]; exclude?: string[] }
) {
	const { include, exclude } = config;
	console.log('debug: | logs:', logs);
	if (include?.length) {
		// if include is set, we only count the included attestations
	}

	if (exclude?.length) {
		// if exclude is set, we only count the excluded attestations
	}
}
