import type { Actions } from './$types';
import { ethers } from 'ethers';
import { SERVER_PRIVATE_KEY, SERVER_RPC_URL } from '$env/static/private';
import AttestationProxy from '$lib/contracts/AttestationProxy';
import { createSignatureMessage } from '$lib/airdrop';

const wallet = new ethers.Wallet(SERVER_PRIVATE_KEY);
const provider = new ethers.providers.JsonRpcProvider(SERVER_RPC_URL);
wallet.connect(provider);

const attestation = new ethers.Contract(AttestationProxy.address, AttestationProxy.abi, wallet);

function verifySignatureMessage(address: string, email: string, score: number, signature: string) {
	const message = createSignatureMessage(address, email, score);
	const recoveredAddress = ethers.utils.verifyMessage(message, signature);
	console.info('verifySignatureMessage', {
		address,
		recoveredAddress,
		message,
		signature,
		success: recoveredAddress.toUpperCase() === address.toUpperCase()
	});
	return recoveredAddress.toUpperCase() === address.toUpperCase();
}

export const actions: Actions = {
	async default(event) {
		const data = await event.request.formData();
		const address = data.get('address') as string;
		const signature = data.get('signature') as string;
		const session = await event.locals.getSession();

		console.info('form submit');
		if (!session?.user) {
			console.warn('claim: not logged in');
			return {
				success: false,
				error: 'You must be logged in to claim the airdrop'
			};
		}

		const email = session.user.email;
		const score = session.user.score;
		if (!email) {
			console.warn('claim: no email');
			return {
				success: false,
				error: 'You must have a verified email to claim the airdrop'
			};
		}

		if (Number(score) < 100) {
			console.warn('claim: invalid score');
			return {
				success: false,
				error: 'Your contribution score is not high enough to claim the airdrop'
			};
		}

		// verify the signature
		if (!verifySignatureMessage(address, email, score, signature)) {
			console.warn('claim: invalid signature');
			return {
				success: false,
				error: 'Invalid signature'
			};
		}

		console.info('claim: attesting to contribution score', score);
		// otherwise we will attest to the user's contribution score
		const tx = attestation.attest(address, 'github.contributions', score);
		let error: string | undefined = undefined;
		const receipt = await tx.wait().caatch((err: Error) => {
			error = err.message;
			return undefined;
		});
		console.info('attestation receipt', receipt);
		if (!receipt?.status) {
			console.warn('claim: invalid receipt status');
			return {
				success: false,
				error: error || 'Failed to attest to contribution score'
			};
		}

		console.info('claim: success');
		return {
			success: true
		};
	}
};
