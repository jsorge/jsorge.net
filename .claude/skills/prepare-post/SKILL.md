---
name: prepare-post
description: Adds Maverick metadata to a new blog post, with AI-suggested tags based on content. Use when asked to prepare a post, add metadata, or suggest tags for a blog post. Defaults to the most recent textbundle in _posts or _drafts.
allowed-tools: Read, Glob, Grep, Edit, AskUserQuestion
---

# Prepare Post Skill

Add Maverick metadata (`io_taphouse_maverick`) to new blog posts. This skill reads the post content and suggests relevant tags based on the writing.

## Finding the Post

1. If a specific post path is provided, use that
2. Otherwise, find the most recent textbundle by modification time in both `Public/_posts/` and `Public/_drafts/`
3. Use `ls -t` to sort by modification time

## Gather Existing Tags

Before suggesting tags, collect all existing tags used across the blog:

```bash
find Public/_posts -name "info.json" -exec jq -r '.io_taphouse_maverick.tags[]? // empty' {} \; | sort | uniq
```

This helps suggest consistent tag naming.

## Read the Post

1. Read `info.json` to check if `io_taphouse_maverick` already exists
2. Read `text.md` to understand the content

If metadata already exists, ask if the user wants to update it.

## Suggest and Confirm Metadata

Based on the post content:

1. **Title**: Suggest a title based on the content, or use the textbundle folder name as a starting point
2. **Short description**: Suggest a 1-2 sentence description that would work well in RSS feeds
3. **Tags**: Suggest relevant tags based on:
   - The post topic and content
   - Existing tags used on the blog (prefer consistency)
   - Common categories like: swift, ios, macos, web, tools, personal, etc.

Present suggestions using AskUserQuestion:

```
Based on your post about [topic], here are my suggestions:

**Title**: [suggested title]
**Description**: [suggested description]
**Tags**: [suggested tags]

Would you like to use these, or customize them?
```

Allow the user to accept, modify, or provide their own values.

## Update info.json

Add the `io_taphouse_maverick` object with these fields:

```json
{
  "io_taphouse_maverick": {
    "date": "YYYY-MM-DDTHH:MM:SSZ",
    "filename": "",
    "layout": "post",
    "microblog": false,
    "shortdescription": "[user-provided description]",
    "staticpage": false,
    "tags": ["tag1", "tag2"],
    "title": "[user-provided title]"
  }
}
```

- **date**: Current UTC time in ISO8601 format
- **filename**: Leave as empty string
- **layout**: Always "post"
- **microblog**: Always false
- **staticpage**: Always false

Use the Edit tool to update info.json, preserving the existing `type` and `version` fields.

## Output

After updating, show the final metadata:

```
Updated [post path] with Maverick metadata:

Title: [title]
Description: [description]
Tags: [tags]
Date: [date]
```

## Important

- Always read the post content before suggesting metadata
- Prefer existing tags for consistency
- Keep descriptions concise (1-2 sentences, suitable for RSS)
- Generate the date at the time of running, not from the post content
