<script lang="ts">
	import { web3 } from '@cinderlink/ui-kit/web3';
	import { onboard, OnboardButton } from '@cinderlink/ui-kit/onboard';
	import CinderAirdrop from '$lib/contracts/CinderAirdrop';
	import { ethers } from 'ethers';
	import { onMount } from 'svelte';
	import type { ActionData, PageData } from './$types';
	import { page } from '$app/stores';

	export let data: PageData;
	export let form: ActionData;

	console.info('server data', form, 'page dataq', data, $page.form);

	let airdrop: ethers.Contract;
	let unclaimed = 0;
	let interval: NodeJS.Timer;
	onMount(async () => {
		await onboard.connectWallet();
		interval = setInterval(checkUnclaimed, 3000);

		return () => {
			clearInterval(interval);
		};
	});

	$: if ($web3.signer) {
		airdrop = new ethers.Contract(CinderAirdrop.address, CinderAirdrop.abi, $web3.signer);
	}

	$: if (airdrop) {
		checkUnclaimed();
	}

	async function checkUnclaimed() {
		if (!$web3.signer || !airdrop) return;
		unclaimed = await airdrop.unclaimed();
		console.info('unclaimed', unclaimed);
	}
</script>

{#if !$web3.signer}
	<p>Connect your wallet to claim your CNDR</p>
	<OnboardButton />
{:else if form?.success}
	{#if unclaimed}
		<button on:click={() => airdrop.claim()}>Claim {unclaimed} CNDR</button>
	{:else}
		<p>You have no unclaimed CNDR</p>
	{/if}
{:else}
	<p>Invalid claim link</p>
{/if}
