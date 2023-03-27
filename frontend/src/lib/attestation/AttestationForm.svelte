<script lang="ts">
	import { Select, Button, Input, Typography } from '@cinderlink/ui-kit';
	import { wallet, wagmi } from 'swagmi';
	import { getProvider, fetchSigner } from '@wagmi/core';

	import { createEventDispatcher } from 'svelte';
	import { attest, calculateAttestationSum, getUserAttestations } from './attestation';

	let address: string;
	let filterAddress: string;
	let key: string;
	let label: string;
	let value: number;
	let selectedKey: 'key' | 'val';
	let selectedFilter: string;
	let filterValue: string;

	const dispatch = createEventDispatcher();

	let attesting = false;
	let error: string | undefined = undefined;
	let success: boolean = false;

	async function submit() {
		if (!$wallet.connected) {
			console.warn(`registry/AttestationForm: No wallet found`);
			error = 'No wallet provider found';
			return;
		}

		const signer = await fetchSigner();
		if (!signer) {
			error = 'No signer found';
			return;
		}

		attesting = true;
		error = undefined;
		success = false;
		const res = await attest(signer, { key, label, value }, address);

		attesting = false;
		key = '';
		label = '';
		value = 0;
		dispatch('submit', { key, label, value });
	}

	async function filterAttestations() {
		if (!$wagmi.connected) return;
		const attestations = await getUserAttestations(filterAddress, getProvider());
		const config = {
			include: selectedFilter === 'include' ? filterValue : undefined,
			exclude: selectedFilter === 'exclude' ? filterValue : undefined,
			attestationKey: selectedKey
		};
		const res = calculateAttestationSum(attestations, config);
		dispatch('filter', res);
	}
</script>

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
<Typography el="h4">Create Attestation</Typography>
<form class="flex flex-col gap-4" on:submit|preventDefault={submit}>
	<Input id="attestation-{address}" placeholder="Address" bind:value={address} />
	<Input id="attestation-{key}" placeholder="Key" bind:value={key} />

	<Input id="attestation-{label}" placeholder="Label" bind:value={label} />

	<Input id="attestation-{value}" placeholder="Value" type="number" bind:value />
	<Button type="submit" variant="green">Create Attestation</Button>
</form>
<br />
<Typography el="h4">Filter Attestations</Typography>
<Input id="attestation-{address}" placeholder="Address" bind:value={filterAddress} />
<form class="flex flex-row gap-4" on:submit|preventDefault={filterAttestations}>
	<div>
		<Select
			id="attestation-keys"
			options={[
				{ label: 'Attestation Key', value: 'key' },
				{ label: 'Attestation Value', value: 'val' }
			]}
			on:selected={(e) => (selectedKey = e.detail.value)}
		/>
	</div>
	<div>
		<Select
			id="attestation-filter"
			options={[
				{ label: 'Includes', value: 'include' },
				{ label: 'Excludes', value: 'exclude' }
			]}
			on:selected={(e) => (selectedFilter = e.detail.value)}
		/>
	</div>
	<Input id="attestation-value" placeholder="Value" bind:value={filterValue} />

	<Button type="submit" variant="green">Filter</Button>
</form>
