#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir/.." rev-parse --show-toplevel)"
changelog="$repo_root/CHANGELOG.md"

git -C "$repo_root" fetch --tags
tag_records="$(git -C "$repo_root" for-each-ref \
	--sort=-creatordate \
	--format='%(refname:short)%09%(creatordate:short)%09%(subject)' \
	refs/tags)"

temp_file="$(mktemp "$repo_root/.CHANGELOG.md.XXXXXX")"
trap 'rm -f "$temp_file"' EXIT

{
	printf '# Changelog\n\n'
	printf 'All notable changes to this module are documented in this file, generated from\n'
	printf 'git tags and commit history.\n\n'

	while IFS=$'\t' read -r tag tag_date tag_message; do
		[[ -n "$tag" ]] || continue
		printf '## %s - %s\n\n%s\n\n' "$tag" "$tag_date" "$tag_message"
	done <<< "$tag_records"
} > "$temp_file"

mv "$temp_file" "$changelog"
trap - EXIT
