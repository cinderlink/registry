import type { Actions } from './$types';
import { ethers } from 'ethers';
import { SERVER_PRIVATE_KEY } from '$env/static/private';
import { createSignatureMessage } from '$lib/airdrop';
import { encodeRawKey } from '$lib/attestation/attestation';
import { fail } from '@sveltejs/kit';
import { AttestationProxy, PermissionRegistry } from '$lib/contracts';

const provider = new ethers.providers.JsonRpcProvider('http://127.0.0.1:8545', 31337);
const wallet = new ethers.Wallet(SERVER_PRIVATE_KEY, provider);
const attestation = new ethers.Contract(AttestationProxy.address, AttestationProxy.abi, wallet);
const permissions = new ethers.Contract(PermissionRegistry.address, PermissionRegistry.abi, wallet);

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
	async default({ request, locals }) {
		const data = await request.formData();
		const address = data.get('address') as string;
		const signature = data.get('signature') as string;
		const session = await locals.getSession();

		if (!session?.user) {
			return fail(400, { success: false, error: 'You must be logged in to claim the airdrop' });
		}

		const email = session.user.email;
		const score = session.user.score;
		if (!email) {
			return fail(400, {
				success: false,
				error: 'You must have a verified email to claim the airdrop'
			});
		}

		if (Number(score) < 100) {
			return fail(400, {
				success: false,
				error: 'You must have at least 100 contributions to claim the airdrop'
			});
		}

		// verify the signature
		if (!verifySignatureMessage(address, email, score, signature)) {
			console.warn('claim: invalid signature');
			return fail(400, { success: false, error: 'Invalid signature' });
		}

		// grant the airdrop.claim permission
		let error: string | undefined = undefined;
		console.info(permissions);
		const hasPermission = await permissions['userHasPermission(address,string)'](
			address,
			'airdrop.claim'
		);
		console.info('hasPermission', hasPermission);
		if (!hasPermission) {
			console.info('user does not have airdrop permission, granting');
			const tx = await permissions['grantPermission(address,string)'](address, 'airdrop.claim');
			const receipt = await tx.wait().catch((err: Error) => {
				error = err.message;
				return undefined;
			});
			console.info('granted airdrop permission', tx.hash, receipt);
			if (!tx.hash) {
				return fail(400, { success: false, error: error || 'Failed to grant claim permission' });
			}
		}

		// otherwise we will attest to the user's contribution score
		const tx = await attestation.attest(
			address,
			encodeRawKey('github.contributions'),
			Math.round(score)
		);
		const receipt = await tx?.wait().catch((err: Error) => {
			error = err.message;
			return undefined;
		});
		console.info('attested', receipt);
		if (!receipt?.hash) {
			return fail(400, { success: false, error: error || 'Failed to claim airdrop' });
		}

		return {
			success: true,
			message: 'Successfully claimed airdrop'
		};
	}
};
