#! /usr/bin/env bash
# Preview the site locally using Apple's container tool
# (https://github.com/apple/container). Runs the Maverick container
# directly with the repo mounted — no nginx, since Maverick serves
# static files itself.
set -euo pipefail

CONTAINER_NAME="maverick-preview"
PORT="${PREVIEW_PORT:-8080}"
MAVERICK_REGISTRY="${MAVERICK_REGISTRY:-ghcr.io/taphouseio/maverick}"

if ! command -v container >/dev/null 2>&1; then
    echo "Apple's container tool is not installed. Install it with:"
    echo "  brew install container"
    exit 1
fi

# Start the container system service if it isn't running. A fresh install
# has no Linux kernel configured and `system start` prompts for one, which
# fails non-interactively — install the recommended kernel and retry.
if ! container system status >/dev/null 2>&1; then
    echo "Starting container system service..."
    if ! container system start </dev/null >/dev/null 2>&1; then
        container system kernel set --recommended
        container system start
    fi
fi

version=$(awk '/^maverickVersion:/{print $2}' SiteConfig.yml)
if [[ -z "$version" ]]; then
    echo "Could not read maverickVersion from SiteConfig.yml"
    exit 1
fi

# Replace any previous preview container
container delete --force "$CONTAINER_NAME" >/dev/null 2>&1 || true

container run --detach --rm \
    --name "$CONTAINER_NAME" \
    --platform linux/amd64 \
    --publish "$PORT:8080" \
    --volume "$PWD/Public:/app/Public" \
    --volume "$PWD/Resources:/app/Resources" \
    --volume "$PWD/SiteConfig.yml:/app/SiteConfig.yml" \
    "$MAVERICK_REGISTRY:$version"

# Wait for Maverick to start answering
for _ in $(seq 1 30); do
    if curl -s -o /dev/null "http://localhost:$PORT/"; then
        echo "Previewing at http://localhost:$PORT"
        exit 0
    fi
    sleep 1
done

echo "Container started but the site isn't responding on port $PORT."
echo "Check logs with: mise run preview-logs"
exit 1
