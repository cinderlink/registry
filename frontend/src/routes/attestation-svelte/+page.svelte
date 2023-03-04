<script>
	import AttestationMenu from '$lib/attestation/AttestationMenu.svelte';
</script>

<AttestationMenu
	entityId={1}
	entityTypeId={2}
	options={[
		{
			key: 'candor.spam',
			label: 'Spam',
			value: 1
		},
		{
			key: 'candor.violence',
			label: 'Voilence',
			value: 2
		},
		{
			key: 'candor.ok',
			label: 'Ok',
			value: 0
		}
	]}
/>
