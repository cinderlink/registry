<script lang="ts">
	import { Markdown } from '@candor/ui-kit';
	import markdown from './overview.md?raw';
</script>

<div class="p-4 pb-20">
	<Markdown value={markdown} />
</div>

<style>
	:global(ul) {
		@apply pl-2 py-2 flex flex-col gap-2 mt-4;
	}
</style>
