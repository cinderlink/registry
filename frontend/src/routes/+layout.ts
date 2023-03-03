export const ssr = false;

export async function load() {
	const contracts = Object.keys(import.meta.glob('./contracts/*.md'))
		.map((path) => {
			const match = path.match(/\/contracts\/(.*)\.md$/);
			if (match) {
				return match[1];
			}
		})
		.filter(Boolean);
	return {
		contracts
	};
}
