<script lang="ts">
	import { onboard } from '@cinderlink/ui-kit/onboard';
	import { web3 } from '@cinderlink/ui-kit';
	import AttestationList from '$lib/attestation/AttestationList.svelte';
	import { Button, Panel, Typography } from '@cinderlink/ui-kit';
	import AttestationForm from '$lib/attestation/AttestationForm.svelte';
	import type { AttestationOutput } from '$lib/attestation/attestation';

	let address = $web3.address;
	console.log('debug: | address:', address);
	let attestations: AttestationOutput[] = [];
	let sum = 0;
	let totalSum = 0;
	let attestationsCount = attestations.length;
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
		<AttestationForm
			on:filter={(e) => {
				attestations = e.detail.attestations;
				sum = e.detail.sum;
				totalSum = e.detail.totalSum;
				attestationsCount = e.detail.attestationsCount;
			}}
		/>
	</Panel>

	<Panel>
		<AttestationList {attestations} {sum} {totalSum} {attestationsCount} />
	</Panel>
{/if}
