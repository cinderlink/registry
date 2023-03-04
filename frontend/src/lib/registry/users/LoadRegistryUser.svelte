<script lang="ts">
	import { ethers } from 'ethers';
	import { UserRegistry } from '$lib/contracts/UserRegistry';
	import { Button } from '@candor/ui-kit/interactive';
	import { web3 } from '@candor/ui-kit/web3';
	import { onboard } from '@candor/ui-kit/onboard';
	import { LoadingIndicator, Typography } from '@candor/ui-kit';

	export let passthrough = false;
</script>

{#if !$web3.connected}
	{#if passthrough}
		<slot user={undefined} connected={false} />
	{:else}
		<slot name="no-wallet">
			<Button on:click={() => onboard.connectWallet()}>
				<div class="i-tabler-wallet" />
				Connect Wallet
			</Button>
		</slot>
	{/if}
{:else}
	{@const contract = new ethers.Contract(UserRegistry.address, UserRegistry.abi, $web3.signer)}
	{#await contract['exists()']()}
		<LoadingIndicator>
			<div class="i-tabler-spinner animate-spin" />
			Checking for registry account...
		</LoadingIndicator>
	{:then exists}
		{#if !exists}
			{#if passthrough}
				<slot user={undefined} connected={true} registered={false} />
			{:else}
				<slot name="unregistered">
					<Typography el="p">It looks like you haven't created a registry account yet.</Typography>
					<Button href="/registry/users/create">
						<div class="i-tabler-user-plus" />
						Create Registry Account
					</Button>
				</slot>
			{/if}
		{:else}
			{#await contract['getUser()']()}
				<LoadingIndicator>
					<div class="i-tabler-spinner animate-spin" />
					Loading registry account...
				</LoadingIndicator>
			{:then user}
				<slot {user} connected={true} registered={true}>
					<Typography el="p">
						Welcome back, {user.name}! Your registered did is {user.did}.
					</Typography>
					<Button href="/registry/users/{user.id}">
						<div class="i-tabler-user" />
						View/Update Account
					</Button>
				</slot>
			{:catch error}
				{#if passthrough}
					<slot {error} user={undefined} registered={undefined} connected={true} />
				{:else}
					<slot name="error" {error}>
						<Typography el="p">There was an error loading your registry account.</Typography>
						<Typography el="p" classes="text-red-400">
							<strong>ERROR:</strong>
							{error.message}
						</Typography>
					</slot>
				{/if}
			{/await}
		{/if}
	{:catch error}
		{#if passthrough}
			<slot {error} user={undefined} registered={undefined} connected={true} />
		{:else}
			<slot name="error" {error}>
				<Typography el="p">There was an error checking for your registry account.</Typography>
				<Typography el="p" classes="text-red-400">
					<strong>ERROR:</strong>
					{error.message}
				</Typography>
			</slot>
		{/if}
	{/await}
{/if}
