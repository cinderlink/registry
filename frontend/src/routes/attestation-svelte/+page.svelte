<script lang="ts">
	import { onboard } from '@candor/ui-kit/onboard';
	import { web3 } from '@candor/ui-kit';
	import AttestationList from '$lib/attestation/AttestationList.svelte';
	import { Button, Panel, Typography } from '@candor/ui-kit';
	import AttestationForm from '$lib/attestation/AttestationForm.svelte';

	let address = $web3.address;
</script>

<Typography el="h4">Attestations</Typography>

{#if !$web3.connected || !$web3.address}
	<Typography classes="text-center">Please connect your wallet</Typography>
	<Button on:click={() => onboard.connectWallet()}>
		>
		<div class="i tabler wallet" />
		Connect Wallet</Button
	>
{:else}
	<Panel classes="gap-4">
		<AttestationForm />
	</Panel>

	<Panel>
		<AttestationList />
	</Panel>
{/if}
