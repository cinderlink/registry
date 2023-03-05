<script lang="ts">
	import { web3 } from '@candor/ui-kit/web3';
	import { OnboardButton } from '@candor/ui-kit/onboard';
	import { Button, Input, Typography } from '@candor/ui-kit';
	import { createSignerDID } from '@candor/identifiers';
	import { ethers } from 'ethers';
	import { UserRegistry } from '$lib/contracts/UserRegistry';

	let contract: ethers.Contract;
	$: if ($web3.connected && $web3.signer) {
		contract = new ethers.Contract(UserRegistry.address, UserRegistry.abi, $web3.signer);
		contract['exists()']().then((exists: boolean) => {
			alreadyRegistered = exists;
		});
	}

	let alreadyRegistered = false;

	let username = '';
	let usernameTaken = false;
	let did = '';
	let error = '';
	let txHash = '';
	let loading = false;

	async function createDID() {
		const generated = await createSignerDID('cinderlink', $web3.signer, 0);
		did = generated.id;
	}

	async function register() {
		loading = true;
		const tx = await contract['register(string,string)'](username, did);
		const receipt = await tx.wait().catch((err: Error) => {
			error = err.message;
		});
		loading = false;
		if (!receipt) return;
		txHash = receipt.transactionHash;
	}

	async function checkUsernameTaken() {
		usernameTaken = await contract['exists(string)'](username);
	}
</script>

<Typography classes="text-purple-600 flex gap-2 items-center">
	<div class="i-tabler-user-plus text-purple-400" />
	Sign up for the Cinderlink Registry
</Typography>

{#if alreadyRegistered}
	<Typography el="h3" classes="text-purple-400">
		Congrats! Your address is already registered in the registry.
	</Typography>
	<Button href="/registry/explorer" variant="green">Explore the registry</Button>
{:else}
	<div class="flex flex-col gap-4 mt-4">
		<Input
			bind:value={username}
			on:blur={checkUsernameTaken}
			id="username"
			label="Username"
			placeholder="@drew"
		/>
		{#if usernameTaken}
			<Typography el="p" classes="text-red-600">
				<div class="i-tabler-alert-triangle" />
				Username is already taken
			</Typography>
		{/if}
		<Input bind:value={did} id="did" label="DID" placeholder="did:ethr:0x..." />
		<section class="text-purple-100 flex flex-col gap-2 justify-center items-end">
			<p class="px-2">
				A DID is a decentralized identifier that is used to identify a user within the Cinderlink
				ecosystem.
			</p>
			{#if !$web3.connected}
				<OnboardButton />
			{:else if !did.length}
				<Button variant="none" classes="text-purple-100" size="sm" on:click={createDID}>
					Generate a DID using a signed entropy message
				</Button>
			{/if}
		</section>

		{#if txHash}
			<Typography el="p" classes="text-green-600">
				<div class="i-tabler-checkmark" />
				Registration complete!
				<span class="text-sm">(tx hash: {txHash})</span>
			</Typography>
		{:else if error}
			<Typography classes="text-red-500">
				<div class="i-tabler-alert-triangle" />
				{error}
			</Typography>
		{/if}

		{#if contract}
			<Button
				disabled={Boolean(loading || !username.length || !did.length || txHash || usernameTaken)}
				variant="green"
				on:click={register}
			>
				{#if loading}
					<div class="i-tabler-loader animate-spin" />
					Loading
				{:else}
					<div class="i-tabler-plus" />
					Complete Registration
				{/if}
			</Button>
		{/if}
	</div>
{/if}
