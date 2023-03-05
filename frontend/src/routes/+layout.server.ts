import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async (event) => {
	const session = await event.locals.getSession();
	const contracts = Object.keys(import.meta.glob('./contracts/*.md'))
		.map((path) => {
			const match = path.match(/\/contracts\/(.*)\.md$/);
			if (match) {
				return match[1];
			}
		})
		.filter(Boolean);
	return {
		session,
		contracts
	};
};

export const ssr = false;
