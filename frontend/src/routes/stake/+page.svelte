<script lang="ts">
	import { CinderStaking, CinderToken } from '$lib/contracts';
	import { Button, Input, Panel, Toggle, Typography } from '@candor/ui-kit';
	import { OnboardButton } from '@candor/ui-kit/onboard';
	import { web3, getContract } from '@candor/ui-kit/web3';
	import { BigNumber, ethers } from 'ethers';
	import { onMount } from 'svelte';

	let balance: BigNumber = BigNumber.from(0);
	let balanceStr = '0';

	let stakedBalance: BigNumber = BigNumber.from(0);
	let stakedBalanceStr = '0';

	let rewardsBalance: BigNumber = BigNumber.from(0);
	let rewardsBalanceStr = '0';

	let delegatedBalance: BigNumber = BigNumber.from(0);
	let delegatedBalanceStr = '0';

	let approving = false;
	let allowance = BigNumber.from(0);

	let token: ethers.Contract | undefined;
	let staking: ethers.Contract | undefined;
	$: token = $web3.signer ? getContract(CinderToken.address, CinderToken.abi) : undefined;
	$: staking = $web3.signer ? getContract(CinderStaking.address, CinderStaking.abi) : undefined;

	let value = 0;

	let interval: NodeJS.Timer;
	onMount(async () => {
		await checkBalances();
		interval = setInterval(checkBalances, 5000);
		return () => {
			clearInterval(interval);
		};
	});

	async function checkBalances() {
		console.info('checking balances', token, staking);
		if (!token) return;
		balance = await token.balanceOf($web3.address);
		balanceStr = ethers.utils.formatUnits(balance, 'wei');

		if (!staking) return;

		stakedBalance = await staking.balanceOf($web3.address).catch(() => BigNumber.from(0));
		stakedBalanceStr = ethers.utils.formatUnits(stakedBalance, 'wei');

		rewardsBalance = await staking.pendingRewards($web3.address).catch(() => BigNumber.from(0));
		rewardsBalanceStr = ethers.utils.formatUnits(rewardsBalance, 'wei');

		delegatedBalance = await staking
			.getDelegatedAmount($web3.address)
			.catch(() => BigNumber.from(0));
		delegatedBalanceStr = ethers.utils.formatUnits(delegatedBalance, 'wei');

		allowance = await token
			.allowance($web3.address, CinderStaking.address)
			.catch(() => BigNumber.from(0));
		console.info('allowance', allowance);
	}

	async function approve() {
		if (!token) return;
		approving = true;
		const tx = await token.approve(CinderStaking.address, ethers.constants.MaxUint256);
		await tx.wait();
		approving = false;
	}

	let stakeSubmitting = false;
	async function submitStake() {
		if (!staking) return;
		stakeSubmitting = true;
		const tx = await staking.stake(BigNumber.from(value));
		await tx.wait();
		stakeSubmitting = false;
		value = 0;
	}

	let agreed = false;
</script>

<Typography>Stake CNDR</Typography>
<Typography el="p">
	By staking at least 1000 CNDR you will gain access to content creation and moderation tools.
</Typography>
<Typography el="p">
	If your contributions to the registry are not aligned with community goals and content moderation
	efforts, your content could be removed and some or all of your staked CNDR could be slashed and
	redistributed to the DAO and other staked users.
</Typography>

{#if $web3.connected}
	<div class="flex flex-row gap-4 items-center justify-end">
		<div class="font-bold text-lg">I understand, I want to stake my CNDR</div>
		<div class="w-64px">
			<Toggle size="xs" id="agreed" bind:toggled={agreed}>
				<div class="font-bold text-sm" slot="off" />
				<div class="font-bold text-sm" slot="on" />
			</Toggle>
		</div>
	</div>

	<p>
		<span class="font-bold">Staked Balance:</span>
		{stakedBalanceStr}
	</p>
	<p>
		<span class="font-bold">Delegated Balance:</span>
		{delegatedBalanceStr}
	</p>

	{#if agreed}
		<form id="staking" on:submit|preventDefault={submitStake}>
			<Panel>
				<Input label="Amount to Stake" id="amount" type="number" bind:value />
				<div class="flex flex-row gap-2 items-center justify-end">
					<Button
						size="sm"
						on:click={() => {
							value = 0;
						}}
					>
						Clear
					</Button>
					<Button
						size="sm"
						on:click={() => {
							value = balance.div(BigNumber.from(10)).toNumber();
						}}
					>
						10%
					</Button>
					<Button
						size="sm"
						on:click={() => {
							value = balance.div(BigNumber.from(4)).toNumber();
						}}
					>
						25%
					</Button>
					<Button
						size="sm"
						on:click={() => {
							value = balance.div(BigNumber.from(2)).toNumber();
						}}
					>
						50%
					</Button>
					<Button
						size="sm"
						on:click={() => {
							value = balance.toNumber();
						}}
					>
						MAX: {balanceStr}
					</Button>
				</div>
				<div class="flex flex-row gap-2 justify-end">
					{#if allowance.gte(BigNumber.from(value))}
						<Button type="submit" variant="dark" size="lg" disabled={stakeSubmitting}>
							<div class={stakeSubmitting ? 'i-tabler-loader animate-spin' : 'i-tabler-shield'} />
							{#if stakeSubmitting}Staking...{:else}Stake{/if}
						</Button>
					{:else}
						<Button on:click={approve} variant="dark" size="lg" disabled={approving}>
							<div class="i-tabler-signature" />
							{#if stakeSubmitting}Approving...{:else}Approve{/if}
						</Button>
					{/if}
				</div>
			</Panel>
		</form>
	{/if}
{:else}
	<OnboardButton />
{/if}
