import { SvelteKitAuth } from '@auth/sveltekit';
import Github, { type GitHubProfile } from '@auth/core/providers/github';
import { AUTH_GITHUB_CLIENT_ID, AUTH_GITHUB_SECRET } from '$env/static/private';

export const handle = SvelteKitAuth({
	providers: [
		Github({
			clientId: AUTH_GITHUB_CLIENT_ID,
			clientSecret: AUTH_GITHUB_SECRET,
			async profile(profile, tokens) {
				return {
					id: profile.login,
					name: profile.name ?? profile.login,
					email: profile.email,
					image: profile.avatar_url,
					profile,
					tokens
				};
			}
		}) as any
	],
	callbacks: {
		async jwt(params) {
			const { token, user, profile } = params;
			token.user = {
				...(user ?? {}),
				profile: { ...(profile ?? {}), ...(user?.profile ?? {}), ...(token?.user?.profile ?? {}) }
			};
			return token;
		},
		async session(params) {
			const { session, token, user } = params;
			const _user = {
				...(user ?? {}),
				...(token.user ?? {}),
				...(session.user ?? {})
			} as any;
			_user.score = _user.profile
				? Number(
						_user.profile.public_repos +
							_user.profile.public_gists +
							_user.profile.followers +
							Number(_user.profile.owned_private_repos) / 4 +
							Number(_user.profile.collaborators) * 5
				  )
				: 0;
			return {
				...session,
				user: _user
			};
		}
	}
});
