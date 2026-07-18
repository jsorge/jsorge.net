#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

MAX_WIDTH="${MAX_WIDTH:-1000}"

if ! command -v magick >/dev/null 2>&1; then
    echo "ImageMagick not installed. Install it with: mise install" >&2
    exit 1
fi

# Collect staged image files (added, copied, or modified)
images=()
while IFS= read -r file; do
    images+=("$file")
done < <(git diff --staged --name-only --diff-filter=ACM | grep -iE '\.(jpe?g|png)$' || true)

if [[ ${#images[@]} -eq 0 ]]; then
    echo "No staged images to resize."
    exit 0
fi

for image in "${images[@]}"; do
    echo "Resizing $image"
    # The > flag only shrinks images wider than MAX_WIDTH; smaller ones are untouched
    magick mogrify -resize "$MAX_WIDTH>" "$image"
    git add "$image"
done

echo "Resized ${#images[@]} image(s) to a max width of ${MAX_WIDTH}px and re-staged them."
