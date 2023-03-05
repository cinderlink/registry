<script lang="ts">
	import { web3 } from '@candor/ui-kit/web3';
	import { OnboardButton } from '@candor/ui-kit/onboard';
	import { signIn, signOut } from '@auth/sveltekit/client';
	import { page } from '$app/stores';
	import { Avatar, Button, LoadingIndicator, Panel, Typography } from '@candor/ui-kit';
	import { createSignatureMessage } from '$lib/airdrop';

	async function prepareSignature() {
		const toSign = createSignatureMessage(
			$web3.address,
			$page.data.session?.user?.email as string,
			$page.data.session?.user?.score as number
		);
		return $web3.signer.signMessage(toSign);
	}
</script>

<Typography el="h1">Cinderlink Attestation</Typography>
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
	We will also airdrop 1000 CNDR tokens to your chosen wallet address, enabling you to be among the
	first to store namespaced relational data within the Cinderlink registry.
</Typography>
<Typography el="p">
	The CNDR token is a utility token used to represent reputational and social capital within the
	Cinderlink ecosystem. It is staked to participate in the governance and moderation of the system
	and is used to pay for storage of definitions within the registry. It is gained by contributing to
	the community and is lost by misbehaving. It is also used to pay for the creation of new registry
	namespaces.
</Typography>

{#if !$web3.signer}
	<OnboardButton />
{:else if $page.data.session?.user}
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
						Your Github contributions have earned you a spot in the first round of the Attestation.
					</Typography>
				</div>
			{:else}
				<div class="p-4 bg-purple-50">
					Unfortunately, you do not have sufficient Github activity to participate in the first
					round of the Attestation. Don't fret, though! We will be running more rounds in the future
					with additional social login metrics (Twitter, Discord, etc...), so please check back
					soon. Perhaps a user who has already participated in the Attestation can vouch for you?
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
		{#await prepareSignature()}
			<LoadingIndicator>Signing claim message...</LoadingIndicator>
		{:then signature}
			<form method="POST" action="/airdrop/claim">
				<input type="hidden" name="address" value={$web3.address} />
				<input type="hidden" name="signature" value={signature} />
				<Button type="submit" width="w-full" size="xl" justify="justify-center" variant="green">
					<div class="i-tabler-parachute" />
					Claim your CNDR!
				</Button>
			</form>
		{:catch error}
			<div class="text-red-500">Error: {error.message}</div>
		{/await}
	</div>
{:else}
	<Typography el="h1">Choose your authentication method</Typography>
	<Button variant="dark" on:click={() => signIn('github')}>
		Sign in with Github <div class="i-logos-github-octocat" />
	</Button>
{/if}
