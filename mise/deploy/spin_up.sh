#! /usr/bin/env bash
source mise/deploy/parse_yaml.sh

# Default registry if not set in environment (e.g., via mise)
MAVERICK_REGISTRY="${MAVERICK_REGISTRY:-ghcr.io/taphouseio/maverick}"

# setup variables
wd=$(pwd)
siteConfigPath="$wd/SiteConfig.yml"
template="$wd/mise/deploy/templates/docker-compose_template.yml"

# copy config
eval $(parse_yaml $siteConfigPath)
config=$(cat $template)
trimmedurl=$(echo "$url" | awk -F/ '{print $3}')
config="${config/'{CONFIG_DOMAIN}'/$trimmedurl}"
config="${config/'{MAVERICK_VERSION}'/$maverickVersion}"
config="${config/'{MAVERICK_REGISTRY}'/$MAVERICK_REGISTRY}"
echo "$config" > $wd/mise/deploy/docker-compose.yml

docker pull "$MAVERICK_REGISTRY:$maverickVersion"

# Maverick's local broadcast state is only a cache; Cloudflare R2 is authoritative.
# Secret files are provisioned separately (normally from 1Password) and never committed.
mkdir -p "$wd/.maverick-secrets" "$wd/.maverick-data"
sudo chown -R 999:999 "$wd/.maverick-secrets" "$wd/.maverick-data"
sudo chmod 700 "$wd/.maverick-secrets" "$wd/.maverick-data"
sudo find "$wd/.maverick-secrets" -type f -exec chmod 400 {} \;

# Ensure directories are writable by the Maverick container.
# The container runs as vapor (uid 999) but files are owned by the host user.
# Maverick needs write access for caching/compiled templates.
chmod -R o+w "$wd/Public" "$wd/Resources" 2>/dev/null || true

docker compose -f mise/deploy/docker-compose.yml up --build -d
