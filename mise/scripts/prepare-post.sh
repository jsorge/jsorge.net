#!/bin/bash
set -e

# Find the newest textbundle by modification time
# Check both _posts and _drafts
POSTS_DIR="Public/_posts"
DRAFTS_DIR="Public/_drafts"

newest_post=""
newest_time=0

# Check _posts
for bundle in "$POSTS_DIR"/*.textbundle; do
    if [[ -d "$bundle" ]]; then
        mod_time=$(stat -f %m "$bundle" 2>/dev/null || echo 0)
        if [[ $mod_time -gt $newest_time ]]; then
            newest_time=$mod_time
            newest_post="$bundle"
        fi
    fi
done

# Check _drafts
for bundle in "$DRAFTS_DIR"/*.textbundle; do
    if [[ -d "$bundle" ]]; then
        mod_time=$(stat -f %m "$bundle" 2>/dev/null || echo 0)
        if [[ $mod_time -gt $newest_time ]]; then
            newest_time=$mod_time
            newest_post="$bundle"
        fi
    fi
done

if [[ -z "$newest_post" ]]; then
    echo "No textbundle found in _posts or _drafts"
    exit 1
fi

INFO_JSON="$newest_post/info.json"

if [[ ! -f "$INFO_JSON" ]]; then
    echo "No info.json found in $newest_post"
    exit 1
fi

# Check if io_taphouse_maverick already exists
if jq -e '.io_taphouse_maverick' "$INFO_JSON" > /dev/null 2>&1; then
    echo "Post already has Maverick metadata: $newest_post"
    echo ""
    echo "Current metadata:"
    jq '.io_taphouse_maverick' "$INFO_JSON"
    echo ""
    read -p "Overwrite? (y/N): " overwrite
    if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

echo "Preparing: $newest_post"
echo ""

# Show the text.md content for context
if [[ -f "$newest_post/text.md" ]]; then
    echo "=== Post content preview ==="
    head -20 "$newest_post/text.md"
    echo ""
    echo "==========================="
    echo ""
fi

# Prompt for title
read -p "Title: " title

# Prompt for short description
read -p "Short description: " shortdescription

# Prompt for tags (comma-separated)
echo "Enter tags (comma-separated, or leave empty):"
read -p "Tags: " tags_input

# Convert comma-separated tags to JSON array
if [[ -z "$tags_input" ]]; then
    tags_json="[]"
else
    # Split by comma, trim whitespace, and create JSON array
    tags_json=$(echo "$tags_input" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | jq -R . | jq -s .)
fi

# Generate the current date in ISO8601 format
current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Build the io_taphouse_maverick object
maverick_obj=$(jq -n \
    --arg date "$current_date" \
    --arg title "$title" \
    --arg shortdescription "$shortdescription" \
    --argjson tags "$tags_json" \
    '{
        date: $date,
        filename: "",
        layout: "post",
        microblog: false,
        shortdescription: $shortdescription,
        staticpage: false,
        tags: $tags,
        title: $title
    }')

# Update the info.json with the new io_taphouse_maverick object
jq --argjson maverick "$maverick_obj" '.io_taphouse_maverick = $maverick' "$INFO_JSON" > "$INFO_JSON.tmp" && mv "$INFO_JSON.tmp" "$INFO_JSON"

echo ""
echo "Updated $INFO_JSON with Maverick metadata:"
jq '.io_taphouse_maverick' "$INFO_JSON"
