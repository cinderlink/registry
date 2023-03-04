<script lang="ts">
	import { web3 } from '@candor/ui-kit';
	import type { ethers } from 'ethers';
	import { onMount } from 'svelte/types/runtime/internal/lifecycle';
	import { getUserAttestations } from './attestation';
	export let address: string;
	export const map: Record<
		string,
		{
			label: string;
			scorer: (value: number) => number;
			priority?: number;
		}
	> = {};

	let attestations: ethers.providers.Log[] = [];
	onMount(async () => {
		attestations = await getUserAttestations(address, $web3.providers.JsonRpcProvider);
		console.log('debug: | attestations:', attestations);
	});
</script>
