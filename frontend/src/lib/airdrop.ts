import { ethers } from 'ethers';

export function createSignatureMessage(address: string, email: string, score: number) {
	console.info({ address, email, score });
	const uintScore = ethers.utils.formatUnits(Math.round(score), 'wei');
	return `signing contribution attestation: ${ethers.utils.solidityKeccak256(
		['address', 'string', 'uint256'],
		[address, email, uintScore]
	)}`;
}
