# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the source repository for jsorge.net, a personal blog powered by Maverick (a Swift-based blog engine). Content is stored as textbundle files and served via Docker containers running Maverick with an Nginx reverse proxy. SSL is handled by Cloudflare (Flexible mode).

## Key Commands

```bash
# Content management
mise run new-draft        # Create a new draft textbundle (prompts for title)
mise run prepare-post     # Add Maverick metadata to newest textbundle
mise run publish-draft    # Move a draft to _posts and commit it

# Local preview (uses Apple's container tool, not Docker)
mise run preview          # Preview the site at http://localhost:8080
mise run preview-draft    # Open a draft at /draft/<slug> (picker if multiple drafts)
mise run preview-down     # Stop the preview container
mise run preview-logs     # View preview container logs

# Server
mise run serve            # Start the site (Cloudflare handles SSL)
mise run down             # Stop Docker containers
mise run docker-logs      # View Maverick container logs

# Styling
mise run build-css        # Rebuild Tailwind CSS (required after style changes)

# Utilities
mise run resize-images    # Optimize images in committed textbundles

# Server management
mise run new-server       # Create and configure a new Digital Ocean droplet
mise run update-ssh-host  # Update GitHub SSH_HOST secret with new server IP
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
- **Tools**: `mise/scripts/` contains bash scripts for tasks, `.tools/` contains Docker/deployment configs

## Deployment

The site deploys automatically via GitHub Actions on push to main. The workflow SSHs into the production server and runs `git pull`. Maverick processes textbundles dynamically—there's no static site build step for content.

## Server Infrastructure

- **Host**: Digital Ocean droplet (Ubuntu LTS)
- **SSH**: `ssh jsorge-net` (configured in ~/.ssh/config)
- **Website location**: `/var/www/jsorge.net`
- **SSL**: Handled by Cloudflare (Flexible mode) - server runs HTTP only on port 80
- **Deployment keys**: Stored in 1Password, installed at `~/.ssh/github_deploy_key` on server

The `new-server` task creates a droplet with Docker, configures SSH keys, and sets up the directory structure. After running, you need to clone the repo and start services manually.

## Creating Posts

Posts are created using an external textbundle editor app. After creating a post, add Maverick metadata:

```bash
mise run prepare-post     # Interactive: prompts for title, description, tags
```

Or use the Claude skill `/prepare-post` for AI-suggested tags based on post content.
