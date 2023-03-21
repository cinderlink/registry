import { describe, it, expect, expectTypeOf } from 'vitest';
import lit from './lit';

describe('lit-protocol', () => {
	it('should encrypt a string', async () => {
		const messageToEncrypt = 'hello world';
		const { encryptedFile, encryptedSymmetricKey } = await lit.encryptString(messageToEncrypt);
		expect(encryptedFile).toBeInstanceOf(Blob);
		expectTypeOf(encryptedSymmetricKey).toBeString();

		const { decryptedFile } = await lit.decryptString(encryptedFile, encryptedSymmetricKey);
		expect(decryptedFile).toBe(messageToEncrypt);
	});
});
