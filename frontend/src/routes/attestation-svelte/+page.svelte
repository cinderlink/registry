<script lang="ts">
	import { Button, Dropdown, List, Panel, theme, Typography, type Size } from '@candor/ui-kit';

	export let entityTypeId: number;
	export let entityId: number;
	export let label: string = 'Choose';
	export let size: Size;
	export let align: 'left' | 'right' = 'left';

	interface AttestationOption {
		key: string;
		label: string;
		value?: number;
		valueFn?: () => number;
	}

	export let options: AttestationOption[] = [];

	let attestationKey: string;
	let attestationValue: number;

	function selectAttestationOption(option: AttestationOption) {
		console.info('Selected attestation', option);
	}
</script>

<Typography el="h1" classes="mb-4">Attestation - Svelte</Typography>

<Panel>
	<Dropdown
		id={`attestation-dropdown-${entityTypeId}-${entityId}`}
		{label}
		{size}
		{align}
		{...$$restProps}
	>
		<List variant={$theme.darkMode ? 'dark' : 'light'} size="sm">
			{#each options as option}
				<Button
					classes="whitespace-nowrap"
					on:click={() => selectAttestationOption(option)}
					size="sm"
				>
					{option.label}
				</Button>
			{/each}
		</List>
	</Dropdown>
</Panel>
