#!/bin/bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
drafts_dir="$repo_root/Public/_drafts"

if ! command -v jq >/dev/null 2>&1; then
    echo "Required command not found: jq" >&2
    exit 1
fi

read -r -p "Title: " title
if [[ -z "$title" ]]; then
    echo "A title is required." >&2
    exit 1
fi

slug=$(echo "$title" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
if [[ -z "$slug" ]]; then
    echo "Could not build a slug from that title." >&2
    exit 1
fi

bundle="$drafts_dir/$slug.textbundle"
if [[ -e "$bundle" ]]; then
    echo "A draft already exists at $bundle" >&2
    exit 1
fi

mkdir -p "$bundle/assets"

current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq -n \
    --arg date "$current_date" \
    --arg title "$title" \
    '{
        version: 2,
        type: "net.daringfireball.markdown",
        transient: false,
        io_taphouse_maverick: {
            date: $date,
            filename: "",
            layout: "post",
            microblog: false,
            shortdescription: "",
            staticpage: false,
            tags: [],
            title: $title
        },
        io_taphouse_maverick_broadcast: {
            providers: {
                bluesky: {skip: false},
                mastodon: {skip: false},
                linkedin: {skip: false}
            }
        }
    }' > "$bundle/info.json"

touch "$bundle/text.md"

echo ""
echo "Created Public/_drafts/$slug.textbundle"
echo "Preview it with: mise run preview-draft"
