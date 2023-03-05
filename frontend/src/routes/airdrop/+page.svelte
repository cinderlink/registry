<script lang="ts">
	import { BigNumber, ethers } from 'ethers';
	import { web3 } from '@candor/ui-kit/web3';
	import { OnboardButton } from '@candor/ui-kit/onboard';
	import { signIn, signOut } from '@auth/sveltekit/client';
	import { page } from '$app/stores';
	import { Avatar, Button, LoadingIndicator, Panel, Typography } from '@candor/ui-kit';
	import { createSignatureMessage } from '$lib/airdrop';
	import { enhance } from '$app/forms';
	import type { Actions } from '@sveltejs/kit';
	import { onMount } from 'svelte';
	import { UserRegistry, CinderAirdrop, AttestationProxy } from '$lib/contracts';

	let loading = false;
	let submitting = false;
	let signing = false;
	let error: string | undefined = undefined;
	let signature: string | undefined = undefined;
	let claimed: BigNumber = BigNumber.from(0);
	let claimedStr: string = '0';
	let unclaimed: BigNumber = BigNumber.from(0);
	let unclaimedStr: string = '0';
	let trust = BigNumber.from(0);
	let isRegistered = false;

	export let form: Actions;
	$: if (form) {
		submitting = false;
		updateTotals();
	}

	let interval: NodeJS.Timer;
	onMount(() => {
		interval = setInterval(updateTotals, 10000);
		return () => clearInterval(interval);
	});

	let airdrop: ethers.Contract;
	let users: ethers.Contract;
	let proxy: ethers.Contract;
	async function loadContracts() {
		if (airdrop && users) return;
		console.info('loading contracts');
		loading = true;
		airdrop = new ethers.Contract(CinderAirdrop.address, CinderAirdrop.abi, $web3.signer);
		users = new ethers.Contract(UserRegistry.address, UserRegistry.abi, $web3.signer);
		proxy = new ethers.Contract(AttestationProxy.address, AttestationProxy.abi, $web3.signer);
		loading = false;
		await updateTotals();
	}

	async function updateTotals() {
		if (!airdrop || !users || loading) return;
		loading = true;
		isRegistered = await users['exists()']();
		unclaimed = await airdrop.unclaimed();
		unclaimedStr = ethers.utils.formatUnits(unclaimed, 'wei');
		claimed = await airdrop.claimed();
		claimedStr = ethers.utils.formatUnits(claimed, 'wei');
		trust = await proxy.trust($web3.address);
		console.info({
			isRegistered,
			claimed,
			claimedStr,
			unclaimed,
			unclaimedStr
		});
		loading = false;
	}

	$: if ($web3.signer && !loading && !users && !airdrop) loadContracts();

	async function sign(e: MouseEvent) {
		e.preventDefault();
		loading = true;
		signing = true;
		const toSign = createSignatureMessage(
			$web3.address,
			$page.data.session?.user?.email as string,
			$page.data.session?.user?.score as number
		);
		signature = await $web3.signer.signMessage(toSign).catch(() => {
			error = 'Signature cancelled or failed';
			return undefined;
		});
		loading = false;
		signing = false;
		return false;
	}

	function submitAttestation() {
		submitting = true;
	}

	let claiming = false;
	let claimHash: string | undefined = undefined;
	async function claim() {
		claiming = true;
		const tx = await airdrop.claim();
		const receipt = await tx.wait();
		claimHash = receipt.hash;
		claiming = false;
	}
</script>

<Typography el="h1">Cinderlink Attestation</Typography>
{#if !isRegistered || unclaimedStr != '0' || claimedStr == '0'}
	<Typography el="p">
		Welcome to the Cinderlink Attestation. To participate in the first round, you must authenticate
		with an active Github account with numerous and frequent contributions to at least one public
		repository.
	</Typography>
	<Typography el="p">
		We will use this information to attest to your identity and our belief that you are a member of
		the community with established reputation who is likely to provide valuable and trustworthy
		contributions to the an information repository.
	</Typography>
	<Typography el="p">
		We will also airdrop 1000 CNDR tokens to your chosen wallet address, enabling you to be among
		the first to store namespaced relational data within the Cinderlink registry.
	</Typography>
	<Typography el="p">
		The CNDR token is a utility token used to represent reputational and social capital within the
		Cinderlink ecosystem. It is staked to participate in the governance and moderation of the system
		and is used to pay for storage of definitions within the registry. It is gained by contributing
		to the community and is lost by misbehaving. It is also used to pay for the creation of new
		registry namespaces.
	</Typography>
{:else}
	<Typography el="p">
		It looks like you have already claimed your airdrop and don't have any additional tokens to
		claim at this time. Provide or moderate well-liked content to increase your chances of
		additional tokens.
	</Typography>
{/if}

{#if !$web3.signer}
	<OnboardButton />
{:else if !isRegistered}
	<Typography el="h2">You aren't registered yet!</Typography>
	<Typography el="p">
		You have to register a user account with the Cinderlink Registry before you can claim the
		airdrop.
	</Typography>
	<Button href="/registry/users/register" variant="yellow" size="lg">
		<div class="i-tabler-user-plus" />
		Register Now
	</Button>
{:else if trust.gt(0)}
	{#if (trust.gt(0) && claimed.eq(0)) || unclaimed.gt(0)}
		<Typography el="h2" classes="text-center">
			You have an attested trust score of {trust}!
			<Button
				type="submit"
				on:click={claim}
				width="w-full"
				size="xl"
				justify="justify-center"
				variant="green"
				disabled={claiming}
			>
				<div class="i-tabler-parachute" />
				Claim your CNDR!
			</Button>
		</Typography>
	{:else if claimed.gt(0)}
		<Panel variant="dark" classes="flex flex-row! gap-2">
			<section class="w-3/4 flex flex-col gap-2 items-center justify-center">
				Success! You have claimed {claimedStr} CNDR tokens and can now contribute to the registry.
			</section>
			<section class="w-1/4 flex flex-col gap-2 items-end justify-start">
				<Button variant="green" width="w-full" href="/stake">
					<div class="i-tabler-shield" />
					Stake CNDR
				</Button>
				<Button variant="blue" width="w-full" href="/registry/explorer">
					<div class="i-tabler-compass" />
					Explore Registry
				</Button>
			</section>
		</Panel>
	{/if}
{:else if claimed.eq(0) && unclaimed.eq(0)}
	{#if $page.data.session?.user}
		<div class="flex flex-col gap-4 my-4">
			<div class="flex gap-4">
				{#if $page.data.session.user.score >= 100}
					<div class="p-8 bg-green-50 flex flex-col items-center justify-center w-1/2 rounded-lg">
						<Typography
							el="h2"
							classes="text-green-800 dark-(text-green-800) flex items-center gap-2"
						>
							<div class="i-tabler-confetti" />
							Congratulations!
						</Typography>
						<Typography el="h4" classes="text-green-700 dark-(text-green-700)">
							Your Github contributions have earned you a spot in the first round of the
							Attestation.
						</Typography>
					</div>
				{:else}
					<div class="p-4 bg-purple-50">
						Unfortunately, you do not have sufficient Github activity to participate in the first
						round of the Attestation. Don't fret, though! We will be running more rounds in the
						future with additional social login metrics (Twitter, Discord, etc...), so please check
						back soon. Perhaps a user who has already participated in the Attestation can vouch for
						you?
					</div>
				{/if}
				<Panel variant="dark" classes="flex-1 w-full h-full flex items-center justify-center">
					<Typography el="h3" classes="text-blue-200">
						Signed in as @{$page.data.session.user.profile?.login}
					</Typography>
					<Avatar image={$page.data.session.user.image || undefined} />
					<div class="text-2xl">Score: {$page.data.session.user.score}</div>
					<div class="w-full flex justify-end">
						<Button justify="justify-end" on:click={() => signOut()}>
							<div class="i-tabler-door-exit" />
							Sign Out
						</Button>
					</div>
				</Panel>
			</div>
			<form method="POST" enctype="multipart/form-data" use:enhance>
				<input type="hidden" name="address" value={$web3.address} />
				<input type="hidden" name="signature" value={signature} />

				{#if submitting}
					<LoadingIndicator>Claiming airdrop...</LoadingIndicator>
				{:else if error}
					<div class="bg-red-300 text-red-900 rounded px-4 py-2">
						{error}
					</div>
				{/if}

				<Button
					type="submit"
					on:click={signature ? submitAttestation : sign}
					width="w-full"
					size="xl"
					justify="justify-center"
					variant={signature ? 'green' : 'blue'}
				>
					<div class={signature ? 'i-tabler-circle-check' : 'i-tabler-signature'} />
					{#if signature}
						Submit attestation
					{:else}
						Sign attestation message
					{/if}
				</Button>
			</form>
		</div>
	{:else}
		<Typography el="h1">Choose your authentication method</Typography>
		<Button variant="dark" on:click={() => signIn('github')}>
			Sign in with Github <div class="i-logos-github-octocat" />
		</Button>
	{/if}
{:else}
	<Typography el="h2">You're in!</Typography>
	<Typography el="p">
		You don't have any unclaimed tokens left, and you have succesfully claimed {claimedStr}
		CNDR tokens.
	</Typography>
	<Button size="lg" color="green" href="/registry">Proceed to the Registry</Button>
{/if}

{#if claimed.gt(0)}
	<Typography el="h5" classes="text-purple-100">
		You have claimed a total of {claimedStr} CNDR tokens.
	</Typography>
{/if}
