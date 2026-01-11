#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}→${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }

# Check for gh CLI
if ! command -v gh &> /dev/null; then
    echo "Error: gh CLI not installed. Install with: brew install gh"
    exit 1
fi

# Check gh auth
if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub. Run: gh auth login"
    exit 1
fi

# Get the IP address
if [ -n "$1" ]; then
    NEW_IP="$1"
elif [ -f .last-droplet-ip ]; then
    NEW_IP=$(cat .last-droplet-ip)
    info "Using IP from .last-droplet-ip: $NEW_IP"
else
    read -p "Enter the new server IP address: " NEW_IP
fi

if [ -z "$NEW_IP" ]; then
    echo "Error: No IP address provided"
    exit 1
fi

# Validate IP format (basic check)
if ! [[ "$NEW_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    warn "Warning: '$NEW_IP' doesn't look like a valid IPv4 address"
    read -p "Continue anyway? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

info "Updating SSH_HOST secret to: $NEW_IP"

# Update the secret
gh secret set SSH_HOST --body "$NEW_IP"

success "SSH_HOST secret updated to $NEW_IP"
echo ""
echo "You can verify at: https://github.com/jsorge/jsorge.net/settings/secrets/actions"
