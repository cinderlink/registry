<script lang="ts">
	import { web3 } from '@candor/ui-kit';
	import { Button, Dropdown, List, Panel, theme, Typography, type Size } from '@candor/ui-kit';
	import { attest, type AttestationOption } from './attestation';
	import type { ethers } from 'ethers';
	export let entityTypeId: number;
	export let entityId: number;
	export let label: string = 'Choose';
	export let size: Size = 'md';
	export let align: 'left' | 'right' = 'left';

	export let options: AttestationOption[] = [];

	let signer: ethers.Signer | undefined = $web3.signer;

	function selectAttestationOption(option: AttestationOption) {
		console.info('Selected attestation', option);
		if (!signer) {
			console.error('No signer found');
			return;
		}
		const res = attest(signer, [option]);
		console.log('debug: | selectAttestationOption | res:', res);
	}
</script>

<Typography el="h1" classes="mb-4">Attestation - Svelte</Typography>

<Panel>
	<Dropdown
		id={`attestation-dropdown-${entityTypeId}-${entityId}`}
		{label}
		{size}
		{align}
		{...$$restProps}
	>
		<List variant={$theme.darkMode ? 'dark' : 'light'} size="sm">
			{#each options as option}
				<Button
					classes="whitespace-nowrap"
					on:click={() => selectAttestationOption(option)}
					size="sm"
				>
					{option.label}
				</Button>
			{/each}
		</List>
	</Dropdown>
</Panel>
