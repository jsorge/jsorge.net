#!/bin/bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
drafts_dir="$repo_root/Public/_drafts"
cd "$repo_root"

PORT="${PREVIEW_PORT:-8080}"

shopt -s nullglob
drafts=("$drafts_dir"/*.textbundle)
shopt -u nullglob

if [[ ${#drafts[@]} -eq 0 ]]; then
    echo "No drafts found in Public/_drafts."
    exit 1
fi

if [[ ${#drafts[@]} -eq 1 ]]; then
    bundle=$(basename "${drafts[0]}")
else
    draft_names=()
    for draft in "${drafts[@]}"; do
        draft_names+=("$(basename "$draft")")
    done

    echo "Choose a draft to preview:"
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
fi

slug=${bundle%.textbundle}
url="http://localhost:$PORT/draft/$slug"

# Start the preview container if the site isn't already responding
if ! curl -s -o /dev/null "http://localhost:$PORT/"; then
    echo "Preview isn't running — starting it..."
    bash mise/scripts/preview.sh
fi

echo "Opening $url"
open "$url"
