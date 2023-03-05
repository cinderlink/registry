<script lang="ts">
	import { Button, Code, Input, Panel, Typography, web3 } from '@candor/ui-kit';
	import { getUserAttestations } from './attestation';

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

	let attestations: Record<string, any>[] = [];

	async function fetchAttestations() {
		if (!$web3.provider) return;
		try {
			attestations = await getUserAttestations(address, $web3.provider);
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
	<Typography el="h4">Attestations List</Typography>
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
	{#if attestations.length}
		{#each attestations as attestation}
			<Panel offset>
				<div class="flex flex-col">
					<strong>Block # {attestation.blockNumber}</strong>
				</div>
				<Code
					lang="javascript"
					code={`{
	address: "${attestation.address}"
	creator: "${attestation.creator}"
	about: "${attestation.about}"
	value: "${attestation.val}"
	key: "${attestation.key}"
}
			`}
				/>
			</Panel>
		{/each}
	{/if}
{/if}
