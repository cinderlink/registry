<script lang="ts">
	import { ethers } from 'ethers';
	import { Button, Input, LoadingIndicator, Panel, Typography } from '@candor/ui-kit';
	import { web3 } from '@candor/ui-kit/web3';
	import { OnboardButton } from '@candor/ui-kit/onboard';
	import { EntityRegistry } from '$lib/contracts/EntityRegistry';
	import { UserRegistry } from '$lib/contracts/UserRegistry';
	import LoadRegistryUser from '$lib/registry/users/LoadRegistryUser.svelte';

	let searched = false;
	let provider: ethers.providers.Provider | ethers.Signer;
	let entities: ethers.Contract;
	let users: ethers.Contract;
	let isReady = false;

	$: {
		provider = $web3.signer || new ethers.providers.JsonRpcProvider();
		entities = new ethers.Contract(EntityRegistry.address, EntityRegistry.abi, provider);
		users = new ethers.Contract(UserRegistry.address, UserRegistry.abi, provider);
	}

	let categoryLoading = false;
	let categoryName = '';
	let categoryTxHash: string | undefined = undefined;
	let categoryTxError: string | undefined = undefined;
	async function createCategory() {
		categoryLoading = true;
		const tx = await entities.register(categoryName, 2).catch((err: Error) => {
			categoryTxError = `contract call failed: ${err.message}`;
			return undefined;
		});
		if (!tx) {
			if (!categoryTxError) {
				categoryTxError = 'contract call failed: unknown error';
			}
			categoryLoading = false;
			return;
		}

		const receipt = await tx.wait().catch((err: Error) => {
			categoryTxError = `tx failed: ${err.message}`;
		});
		if (!receipt) {
			categoryLoading = false;
			return;
		}

		categoryTxHash = receipt.transactionHash;
		categoryLoading = false;
	}
</script>

<Typography classes="text-purple-700 dark-(text-yellow-200) flex items-center gap-4">
	<div class="i-tabler-compass text-purple-300" />
	Explore the Cinderlink Registry
</Typography>

{#if !$web3.connected}
	<Panel invert classes="mb-8">
		<div class="flex flex-row gap-2 items-center justify-between">
			<div class="flex-1 flex flex-row gap-4 items-center justify-center">
				<div
					class="i-tabler-alert-triangle-filled text-yellow-400 dark-(text-yellow-100) text-3xl"
				/>
				<Typography el="h3" classes="text-2xl">
					You must connect a Wallet to contribute data to the registry
				</Typography>
			</div>
			<OnboardButton variant="green" />
		</div>
	</Panel>
{/if}

<div class="flex flex-col gap-2 items-end justify-start">
	<Input id="registry_search" placeholder="Search" />
	<Button variant="blue">
		<div class="i-tabler-search" />
		Search
	</Button>
</div>

{#if !searched}
	<section class="flex flex-col gap-8 mt-8">
		<Panel>
			<Typography el="h3">Categories</Typography>
			<Typography el="p" classes="px-4 text-purple-100 mb-8">
				{#await entities.getEntitiesByType(2, 0, 100)}
					<LoadingIndicator>Loading categories...</LoadingIndicator>
				{:then categories}
					{#if !categories.length}
						<Typography el="p">
							No categories found. {#if $web3.connected}Create one below.{:else}Connect a wallet to
								create one.{/if}
						</Typography>
					{:else}
						{#each categories as category}
							<Typography el="p">
								{category}
							</Typography>
						{/each}
					{/if}
				{/await}
			</Typography>
			<LoadRegistryUser>
				<Panel variant="offset">
					<Typography el="h4" classes="text-purple-500 dark-(text-yellow-200)">
						Create a Category
					</Typography>
					<form on:submit|preventDefault={createCategory} class="flex flex-row gap-2">
						<Input
							id="category_name"
							bind:value={categoryName}
							type="text"
							placeholder="Category name"
							disabled={categoryLoading}
						/>
						<Button disabled={categoryLoading} type="submit" variant="green">
							{#if categoryLoading}
								<div class="i-tabler-loader animate-spin" />
								Sending Tx
							{:else}
								<div class="i-tabler-plus" />
								Create
							{/if}
						</Button>
					</form>

					{#if categoryTxHash}
						<Typography el="p" classes="text-purple-500 dark-(text-yellow-200)">
							tx hash: {categoryTxHash}
						</Typography>
					{:else if categoryTxError}
						<Typography el="p" classes="text-red-500 dark-(text-red-200)">
							{categoryTxError}
						</Typography>
					{/if}
				</Panel>

				<svelte:fragment slot="unregistered">
					<Panel variant="offset" size="sm">
						<Typography el="h4" classes="text-purple-500 dark-(text-yellow-200) px-1">
							You must register a user to create a category
						</Typography>
						<Button variant="green" href="/registry/users/register">
							<div class="i-tabler-plus" />
							Register
						</Button>
					</Panel>
				</svelte:fragment>
			</LoadRegistryUser>
		</Panel>

		<Panel>Explore schemas</Panel>

		<Panel>Explore entities</Panel>

		<Panel>Explore definitions</Panel>
	</section>
{/if}
