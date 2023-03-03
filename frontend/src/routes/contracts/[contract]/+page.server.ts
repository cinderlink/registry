import type { PageServerLoad } from './$types';
import fs from 'fs';

export async function load({ params }: PageServerLoad) {
	const { contract } = params;
	const markdown = fs.readFileSync(`./src/routes/contracts/${contract}.md`, 'utf8');
	return {
		markdown
	};
}
