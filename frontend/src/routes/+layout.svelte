<script lang="ts">
	import { Button, Drawer, Logo, SidebarLayout, Theme } from '@candor/ui-kit';
	import type { LayoutData } from './$types';
	import './layout.css';

	export let data: LayoutData;
	console.info('data', data);
</script>

<Theme>
	<SidebarLayout>
		<div slot="sidebar" class="flex-1 flex flex-col gap-4 items-start justify-start">
			<div class="flex w-full justify-center items-center">
				<Logo />
			</div>
			<a id="brand" href="/">@candor/registry</a>
			<nav class="flex-1 flex flex-col gap-2">
				<Drawer label="Guides">
					<ul>
						<li>
							<a href="/guides/getting-started">Getting Started</a>
						</li>
					</ul>
				</Drawer>

				<Drawer label="Contracts">
					<ul>
						{#each data.contracts as contract}
							<li>
								<Button
									size="sm"
									justify="justify-start"
									variant="none"
									href="/contracts/{contract}"
								>
									{contract}
								</Button>
							</li>
						{/each}
					</ul>
				</Drawer>

				<Drawer label="Libraries">
					<ul>
						<li>
							<a href="/libraries/ui-kit">UI Kit</a>
						</li>
					</ul>
				</Drawer>
			</nav>
		</div>
		<main>
			<slot />
		</main>
	</SidebarLayout>
</Theme>

<style>
	ul {
		@apply pl-2 py-2 flex flex-col gap-2;
	}
	ul > li {
		@apply px-4 py-2 rounded-md hover-(bg-purple-100) dark-(hover-bg-purple-900);
	}
	ul > li > a {
		@apply text-md text-purple-800 dark-(text-yellow-100);
	}
	main {
		@apply px-8 py-2 bg-purple-50/5;
	}
</style>
