import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vitest/config';

export default defineConfig({
	plugins: [sveltekit()],
	test: {
		deps: {
			inline: ['@ethersproject/signing-key', '@ethersproject/basex']
		},
		include: ['src/**/*.{test,spec}.{js,ts}']
	}
});
