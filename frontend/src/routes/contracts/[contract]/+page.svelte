<script lang="ts">
	import { Markdown } from '@cinderlink/ui-kit';
	import type { PageData } from './$types';

	export let data: PageData;
</script>

<Markdown value={data.markdown} />
