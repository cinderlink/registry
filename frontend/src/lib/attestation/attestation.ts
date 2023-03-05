import { ethers } from 'ethers';
import { AttestationStation } from '$lib/contracts/AttestationStation';

export interface AttestationOption {
	key: string;
	label: string;
	value?: number;
	valueFn?: (address: string) => number;
}

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
	attestation: AttestationOption,
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
	let result: Record<string, unknown>[] = [];
	// const abiCoder = new ethers.utils.AbiCoder();
	const interF = new ethers.utils.Interface(AttestationStation.abi);
	logs.map((log) => {
		// console.log('debug: | logs.map | log:', log);
		// // const decoded = abiCoder.decode(['address', 'address', 'bytes32', 'bytes'], log.data);
		// const about = abiCoder.decode(['address', 'bytes'], log.data, true);
		// console.log('debug: | logs.map | decoded:', about);
		const parsed = interF.parseLog(log);
		result = [...result, { blockNumber: log.blockNumber, address: log.address, ...parsed.args }];
	});
	return result;
}

export function calculateAttestationSum(
	logs: ethers.providers.Log[],
	config: { include?: string[]; exclude?: string[] }
) {
	const { include, exclude } = config;
	if (include?.length) {
		// if include is set, we only count the included attestations
	}

	if (exclude?.length) {
		// if exclude is set, we only count the excluded attestations
	}
}
