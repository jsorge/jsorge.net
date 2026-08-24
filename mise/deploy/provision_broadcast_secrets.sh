#!/usr/bin/env bash
set -euo pipefail
umask 077

if ! command -v op >/dev/null 2>&1; then
    echo "1Password CLI (op) is required" >&2
    exit 1
fi

mode="install"
if [[ "${1:-}" == "--check" ]]; then
    mode="check"
    shift
fi

if (($# > 1)); then
    echo "Usage: $0 [--check] [target-directory]" >&2
    exit 64
fi

if ! op user get --me >/dev/null 2>&1; then
    if [[ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
        echo "1Password rejected OP_SERVICE_ACCOUNT_TOKEN; verify the token and service-account status." >&2
    else
        echo "1Password CLI is not signed in. Run 'eval \$(op signin)' and retry." >&2
    fi
    exit 1
fi

target="${1:-$PWD/.maverick-secrets}"
item="${OP_MAVERICK_ITEM:-op://jsorge.net/Maverick Broadcast}"
temporary="$(mktemp -d /tmp/maverick-broadcast-secrets.XXXXXX)"
trap 'rm -rf "$temporary"' EXIT

secrets=(
    cloudflare-r2-account-id
    cloudflare-r2-access-key-id
    cloudflare-r2-secret-access-key
    maverick-state-encryption-key
    maverick-admin-username
    maverick-admin-password
    bluesky-app-password
    mastodon-access-token
    linkedin-client-id
    linkedin-client-secret
)

for name in "${secrets[@]}"; do
    if ! op read "$item/$name" >"$temporary/$name"; then
        echo "Could not read 1Password field: $item/$name" >&2
        exit 1
    fi
    if [[ ! -s "$temporary/$name" ]]; then
        echo "1Password field is empty: $item/$name" >&2
        exit 1
    fi
done

if [[ "$mode" == "check" ]]; then
    echo "1Password integration is ready: read ${#secrets[@]} non-empty fields from $item"
    exit 0
fi

sudo install -d -o 999 -g 999 -m 0700 "$target"
for name in "${secrets[@]}"; do
    sudo install -o 999 -g 999 -m 0400 "$temporary/$name" "$target/$name"
done

echo "Installed ${#secrets[@]} read-only secret files in $target"
