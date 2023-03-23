<script lang="ts">
	import { Button, Code, Input, Panel, Typography, web3 } from '@cinderlink/ui-kit';
	import { onMount } from 'svelte';
	import {
		attestationCreatedListener,
		getUserAttestations,
		type AttestationOutput
	} from './attestation';

	let address: string;
	let notFound = false;
	export const map: Record<
		string,
		{
			label: string;
			scorer: (value: number) => number;
			priority?: number;
		}
	> = {};

	export let attestations: AttestationOutput[] = [];
	export let totalSum = 0;
	export let attestationsCount = attestations.length;
	export let sum = 0;
	onMount(async () => {
		if (!$web3.provider) return;
		const newAttestation = await attestationCreatedListener($web3.provider);
		attestations = [...attestations, newAttestation];
	});

	async function fetchAttestations() {
		if (!$web3.provider) return;
		try {
			attestations = await getUserAttestations(address, $web3.provider);
			attestationsCount = attestations.length;
			notFound = false;
		} catch (error) {
			console.error('fetchAttestations - error:', error);
			notFound = true;
		}
		if (!attestations.length) {
			notFound = true;
			return;
		}
	}
</script>

{#if !$web3}
	<div class="flex items-center gap-2 p-4 rounded-md bg-yellow-500 text-yellow-900">
		<div class="i-tabler-alert-triangle" />
		<strong>No wallet provider found</strong>
	</div>
{:else}
	<div class="flex justify-between">
		<Typography el="h4">Attestations List</Typography>
		<div class="flex">
			<span><strong>Sum: {sum}</strong></span>
			<span class="mx-2">/</span>
			<span>{totalSum}</span>
			<span class="mx-2">|</span>
			<span><strong>count: {attestationsCount}</strong></span>
		</div>
	</div>
	<form class="flex items-center gap-2" on:submit|preventDefault={fetchAttestations}>
		<Input id="attestation-{address}" placeholder="Fetch by address" bind:value={address} />
		<Button type="submit" variant="green">Fetch</Button>
	</form>
	{#if notFound}
		<div class="flex items-center gap-2 p-4 rounded-md bg-yellow-500 text-yellow-900">
			<div class="i-tabler-alert-triangle" />
			<strong>No attestations found</strong>
		</div>
	{/if}
	<Panel classes="flex-col-reverse">
		{#if attestations.length}
			{#each attestations as attestation, i}
				<Panel offset>
					<div class="flex flex-col">
						<strong># {i + 1}</strong>
					</div>
					<Code
						lang="javascript"
						code={`{
	creator: "${attestation.creator}"
	about: "${attestation.about}"
	val: ${Number(attestation.val)}
	key: "${attestation.key}"
}
			`}
					/>
				</Panel>
			{/each}
		{/if}
	</Panel>
{/if}
