#!/bin/bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
drafts_dir="$repo_root/Public/_drafts"
posts_dir="$repo_root/Public/_posts"
cd "$repo_root"

for command in git jq; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Required command not found: $command" >&2
        exit 1
    fi
done

shopt -s nullglob
drafts=("$drafts_dir"/*.textbundle)
shopt -u nullglob

if [[ ${#drafts[@]} -eq 0 ]]; then
    echo "No textbundles found in Public/_drafts."
    exit 1
fi

draft_names=()
for draft in "${drafts[@]}"; do
    draft_names+=("$(basename "$draft")")
done

echo "Choose a draft to publish:"
PS3="> "
select bundle in "${draft_names[@]}" "Cancel"; do
    if [[ "$bundle" == "Cancel" ]]; then
        echo "Cancelled."
        exit 0
    fi

    if [[ -n "$bundle" ]]; then
        break
    fi

    echo "Please enter a number from 1 to $((${#drafts[@]} + 1))."
done

source=${drafts[$((REPLY - 1))]}
name=${bundle%.textbundle}
published_bundle="$(date +%Y-%m-%d)-$bundle"
destination="$posts_dir/$published_bundle"
source_relative="Public/_drafts/$bundle"
destination_relative="Public/_posts/$published_bundle"
info_json="$source/info.json"

if [[ ! -f "$info_json" ]]; then
    echo "Missing metadata file: $info_json" >&2
    exit 1
fi

if ! jq -e '.io_taphouse_maverick | type == "object"' "$info_json" >/dev/null; then
    echo "Missing io_taphouse_maverick metadata in $info_json" >&2
    exit 1
fi

if [[ -e "$destination" ]]; then
    echo "A published bundle already exists at $destination" >&2
    exit 1
fi

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
temporary_info="$info_json.tmp"
trap 'rm -f "$temporary_info"' EXIT
jq --arg date "$timestamp" '
    .io_taphouse_maverick.date = $date |
    .io_taphouse_maverick_broadcast = ({
        providers: {
            bluesky: {skip: false},
            mastodon: {skip: false},
            linkedin: {skip: false}
        }
    } * (.io_taphouse_maverick_broadcast // {}))
' \
    "$info_json" > "$temporary_info"
mv "$temporary_info" "$info_json"
trap - EXIT

git add -- "$source_relative"
git mv "$source" "$destination"

staged_paths=()
while IFS= read -r path; do
    staged_paths+=("$path")
done < <(git diff --cached --name-only -- "$source_relative" "$destination_relative")

git commit -m "published $name" -- "${staged_paths[@]}"

echo "Published $published_bundle at $timestamp"
