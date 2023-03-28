import LitJsSdk from '@lit-protocol/lit-node-client';
import * as u8a from 'uint8arrays';
import * as ethers from 'ethers';
import siwe from 'siwe';
import { WALLET_PRIVATE_KEY } from '$env/static/private';

const client = new LitJsSdk.LitNodeClient({
	alertWhenUnauthorized: false
});

const chain = 'ethereum';

// const accessControlConditionsNFT = [
// 	{
// 		contractAddress: '0x2bdCC0de6bE1f7D2ee689a0342D76F52E8EFABa3',
// 		standardContractType: 'ERC721',
// 		chain,
// 		method: 'addressHasToken',
// 		parameters: [':address', '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'],
// 		returnValueTest: {
// 			comparator: '==',
// 			value: 'true'
// 		}
// 	}
// ];

const accessControlConditions = [
	{
		contractAddress: '',
		standardContractType: '',
		chain: 'ethereum',
		method: 'eth_getBalance',
		parameters: [':userAddress', 'latest'],
		returnValueTest: {
			comparator: '>=',
			value: '0' // 0 ETH, so anyone can open
		}
	}
];

class Lit {
	private litNodeClient: LitJsSdk.LitNodeClient | undefined;

	async connect() {
		await client.connect();
	}

	/***
	 * Get auth signature using siwe
	 * @returns
	 */
	signAuthMessage = async () => {
		// Replace this with you private key
		// const privKey = '3dfb4f70b15b6fccc786347aaea445f439a7f10fd10c55dd50cafc3d5a0abac1';
		// const privKeyBuffer = u8a.fromString(privKey, 'base16');
		const wallet = new ethers.Wallet(WALLET_PRIVATE_KEY);

		const domain = 'localhost';
		const origin = 'https://localhost:5173';
		const statement = 'This is a test statement.  You can put anything you want here.';

		const siweMessage = new siwe.SiweMessage({
			domain,
			address: wallet.address,
			statement,
			uri: origin,
			version: '1',
			chainId: 1
		});

		const messageToSign = siweMessage.prepareMessage();

		const signature = await wallet.signMessage(messageToSign);

		console.log('signature', signature);

		const recoveredAddress = ethers.utils.verifyMessage(messageToSign, signature);

		const authSig = {
			sig: signature,
			derivedVia: 'web3.eth.personal.sign',
			signedMessage: messageToSign,
			address: recoveredAddress
		};

		return authSig;
	};

	async encryptString(str: string) {
		const authSig = await this.signAuthMessage();
		if (!this.litNodeClient) {
			await this.connect();
			this.litNodeClient = client;
		}

		const { encryptedString, symmetricKey } = await LitJsSdk.encryptString(str);

		const encryptedSymmetricKey = await this.litNodeClient.saveEncryptionKey({
			accessControlConditions: accessControlConditions,
			symmetricKey,
			authSig,
			chain
		});

		return {
			encryptedFile: encryptedString,
			encryptedSymmetricKey: LitJsSdk.uint8arrayToString(encryptedSymmetricKey, 'base16')
		};
	}

	async decryptString(encryptedStr: Blob, encryptedSymmetricKey: string) {
		if (!this.litNodeClient) {
			await this.connect();
			this.litNodeClient = client;
		}
		const authSig = await this.signAuthMessage();
		const symmetricKey = await this.litNodeClient.getEncryptionKey({
			accessControlConditions: accessControlConditions,
			toDecrypt: encryptedSymmetricKey,
			chain,
			authSig
		});
		const decryptedFile = await LitJsSdk.decryptString(encryptedStr, symmetricKey);

		return { decryptedFile };
	}
}

export default new Lit();
