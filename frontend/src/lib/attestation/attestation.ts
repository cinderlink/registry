import { ethers } from 'ethers';
import { AttestationStation } from '$lib/contracts/AttestationStation';

export interface AttestationInput {
	key: string;
	label: string;
	value?: number;
	valueFn?: (address: string) => number;
}

export type AttestationOutput = {
	creator: string;
	about: string;
	key: string;
	val: number;
	tx: unknown;
};

export function getContract(
	address: string,
	abi: ethers.Contract['JSONInterface'],
	singerOrProvider: ethers.Signer | ethers.providers.Provider
): ethers.Contract {
	return new ethers.Contract(address, abi, singerOrProvider);
}

export function encodeRawKey(key: string) {
	if (key.length < 32) return ethers.utils.formatBytes32String(key);

	const hash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(key));
	return hash.slice(0, 64) + 'ff';
}

export async function attest(
	signer: ethers.Signer,
	attestation: AttestationInput,
	address: string
) {
	const contract = getContract(AttestationStation.address, AttestationStation.abi, signer);
	if (!contract) {
		return 'No AttestationStation contract found';
	}
	const tx = await contract.attest([
		{
			about: address,
			key: encodeRawKey(attestation.key),
			val: attestation.value ?? attestation.valueFn?.(address)
		}
	]);

	const receipt = await tx.wait();

	return receipt;
}

export async function getUserAttestations(address: string, provider: ethers.providers.Provider) {
	const contract = getContract(AttestationStation.address, AttestationStation.abi, provider);
	const filter = await contract.filters.AttestationCreated(address);
	const logs = await contract.queryFilter(filter);
	const resutls: AttestationOutput[] = [];
	logs.map((log) => {
		const [creator, about, key, val] = log.args as [string, string, string, string];
		resutls.push({
			creator,
			about,
			key: ethers.utils.parseBytes32String(key),
			val: Number(val),
			tx: log.transactionHash
		});
	});
	return resutls;
}

export function attestationCreatedListener(
	provider: ethers.providers.Provider
): Promise<AttestationOutput> {
	const contract = getContract(AttestationStation.address, AttestationStation.abi, provider);
	return new Promise((resolve) => {
		contract.once('AttestationCreated', (creator, about, key, val, tx) => {
			return resolve({
				creator,
				about,
				key: ethers.utils.parseBytes32String(key),
				val: Number(val),
				tx
			});
		});
	});
}

export function calculateAttestationSum(
	attestations: AttestationOutput[],
	config: { include?: string; exclude?: string; attestationKey: 'key' | 'val' }
): { sum: number; totalSum: number; attestationsCount: number; attestations: AttestationOutput[] } {
	const { include, exclude, attestationKey } = config;
	const result: AttestationOutput[] = [];
	let sum = 0;
	let totalSum = 0;
	attestations.map((att) => {
		totalSum += att.val;
	});

	if (include?.length) {
		attestations.map((att) => {
			if (attestationKey === 'val') {
				if (Number(att[attestationKey]) === Number(include)) {
					result.push(att);
					sum += att.val;
				}
			} else if (attestationKey === 'key') {
				if (att[attestationKey].includes(include)) {
					result.push(att);
					sum += att.val;
				}
			}
		});
	}

	if (exclude?.length) {
		attestations.map((att) => {
			if (attestationKey === 'val') {
				if (Number(att[attestationKey]) !== Number(exclude)) {
					result.push(att);
					sum += att.val;
				}
			} else if (attestationKey === 'key') {
				if (!att[attestationKey].includes(exclude)) {
					result.push(att);
					sum += att.val;
				}
			}
		});
	}

	const attestationsCount = result.length;

	return { sum, totalSum, attestationsCount, attestations: result };
}
