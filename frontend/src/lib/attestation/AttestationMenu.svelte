<script lang="ts">
	import { LoadingIndicator, web3 } from '@cinderlink/ui-kit';
	import { Button, Dropdown, List, Panel, theme, Typography, type Size } from '@cinderlink/ui-kit';
	import { attest, type AttestationInput } from './attestation';
	import { onboard } from '@cinderlink/ui-kit/onboard';

	export let address: string;
	export let label: string;
	export let size: Size = 'md';
	export let align: 'left' | 'right' = 'left';

	export let options: AttestationInput[] = [];

	let attesting = false;
	let error: string | undefined = undefined;
	let success: boolean = false;

	async function selectAttestationOption(option: AttestationInput) {
		if (!$web3.provider) {
			console.warn(`ui-kit/AttestationMenu: No wallet provider found`, $web3);
			error = 'No wallet provider found';
			return;
		}

		if (!$web3.signer) {
			error = 'No signer found';
			return;
		}
		attesting = true;
		error = undefined;
		success = false;
		await attest($web3.signer, option, address);
		attesting = false;
	}
</script>

{#if !$web3.connected}
	<Panel>
		<Typography classes="text-center">Please connect your wallet</Typography>
	</Panel>
	<Button on:click={() => onboard.connectWallet()}>
		>
		<div class="i tabler wallet" />
		Connect Wallet</Button
	>
{:else}
	{#if success}
		<div class="p-4 rounded-md bg-green-500 text-green-900">
			<strong>Success!</strong>
			<p>Attestation sent</p>
		</div>
	{:else if error}
		<div class="p-4 rounded-md bg-red-500 text-red-900">
			<strong>Error!</strong>
			<p>{error}</p>
		</div>
	{/if}

	{#if attesting}
		<LoadingIndicator>Submitting feedback...</LoadingIndicator>
	{:else}
		<Dropdown id={`attestation-dropdown-${address}`} {label} {size} {align} {...$$restProps}>
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
	{/if}
{/if}
