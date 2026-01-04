# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the source repository for jsorge.net, a personal blog powered by Maverick (a Swift-based blog engine). Content is stored as textbundle files and served via Docker containers running Maverick with an Nginx reverse proxy.

## Key Commands

```bash
# Content management
make newpost              # Create a new blog post (prompts for title)
make publish              # Commit, push, and deploy to production

# Development
make dev                  # Start local dev server (no SSL)
make serve                # Start production server with SSL
make down                 # Stop Docker containers
make docker-logs          # View Maverick container logs

# Styling
make build-css            # Rebuild Tailwind CSS (required after style changes)

# Utilities
make resize-images        # Optimize images in committed textbundles
make renew-ssl            # Renew Let's Encrypt certificates
```

## Textbundle Post Format

Posts are stored as textbundle directories following the spec at https://textbundle.org/spec:

```
YYYY-MM-DD-slug.textbundle/
├── info.json      # Metadata (title, date, tags, etc.)
├── text.md        # Markdown content
└── assets/        # Images and attachments
```

The `info.json` structure includes Maverick-specific metadata under `io_taphouse_maverick`:
- `date`: ISO8601 timestamp
- `title`: Post title
- `tags`: Array of tag strings
- `shortdescription`: Excerpt for feeds
- `microblog`: Boolean for micro.blog cross-posting
- `staticpage`: Boolean (true for pages like "about")

## Architecture

- **Content**: `Public/_posts/` (published), `Public/_drafts/` (unpublished), `Public/_pages/` (static pages)
- **Templates**: `Resources/Views/*.leaf` (Vapor's Leaf templating)
- **Styles**: `styles/styles.source.css` (Tailwind source) → `Public/styles/styles.css` (built)
- **Configuration**: `SiteConfig.yml` (site metadata, Maverick version, feed settings)
- **Tools**: `tools/` contains Swift scripts using swift-sh, `.tools/` contains Docker/deployment configs

## Deployment

The site deploys automatically via GitHub Actions on push to main. The workflow SSHs into the production server and runs `git pull`. Maverick processes textbundles dynamically—there's no static site build step for content.

## Creating Posts

New posts can be created via:
```bash
make newpost
# or directly:
./vendor/swift-sh ./tools/NewBlogPost.swift "Post Title"
./vendor/swift-sh ./tools/NewBlogPost.swift --draft "Draft Title"
```

This creates the textbundle structure with proper metadata and opens it in BBEdit.
