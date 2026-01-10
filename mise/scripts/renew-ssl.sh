#!/usr/bin/env bash

set -e
set -o pipefail

# Stop containers
docker-compose -f ./.tools/docker-compose.yml down

# Remove old SSL certificates
sudo rm -rf ./.tools/nginx/ssl

# Start server to get new certificates
./.tools/spin_up.sh
