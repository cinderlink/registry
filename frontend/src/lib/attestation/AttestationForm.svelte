<script lang="ts">
	import { web3 } from '@candor/ui-kit';
	import { Button, Input, Panel, Typography } from '@candor/ui-kit';
	import { createEventDispatcher } from 'svelte';
	import { attest } from './attestation';

	let address: string;
	let key: string;
	let label: string;
	let value: number;
	const dispatch = createEventDispatcher();

	let attesting = false;
	let error: string | undefined = undefined;
	let success: boolean = false;

	async function submit() {
		console.log('submitting', { key, label, value });
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
		const res = await attest($web3.signer, { key, label, value }, address);

		attesting = false;
		dispatch('submit', { key, label, value });
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
<form class="flex flex-col gap-4" on:submit|preventDefault={submit}>
	<Input id="attestation-{address}" placeholder="Address" bind:value={address} />
	<Input id="attestation-{key}" placeholder="Key" bind:value={key} />

	<Input id="attestation-{label}" placeholder="Label" bind:value={label} />

	<Input id="attestation-{value}" placeholder="Value" type="number" bind:value />
	<Button type="submit" variant="green">Submit</Button>
</form>
