<script lang="ts">
	import { web3 } from '@candor/ui-kit/web3';
	import AttestationMenu from '$lib/attestation/AttestationMenu.svelte';
	import { Button } from '@candor/ui-kit';
	import { getUserAttestations } from '$lib/attestation/attestation';
	import { ethers } from 'ethers';

	const address = $web3.address;
</script>

<AttestationMenu
	label="Attestation"
	{address}
	options={[
		{
			key: 'candor.spam',
			label: 'Spam',
			value: 1
		},
		{
			key: 'candor.violence',
			label: 'Voilence',
			value: 2
		},
		{
			key: 'candor.ok',
			label: 'Ok',
			value: 0
		}
	]}
/>

<Button on:click={() => getUserAttestations(address, new ethers.providers.JsonRpcProvider())}>
	Get Attestations
</Button>
