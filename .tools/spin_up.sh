#! /usr/bin/env bash
source .tools/parse_yaml.sh

# Default registry if not set in environment (e.g., via mise)
MAVERICK_REGISTRY="${MAVERICK_REGISTRY:-ghcr.io/taphouseio/maverick}"

# setup variables
wd=$(pwd)
siteConfigPath="$wd/SiteConfig.yml"
template="$wd/.tools/templates/docker-compose_template.yml"

# copy config
eval $(parse_yaml $siteConfigPath)
config=$(cat $template)
trimmedurl=$(echo "$url" | awk -F/ '{print $3}')
config="${config/'{CONFIG_DOMAIN}'/$trimmedurl}"
config="${config/'{MAVERICK_VERSION}'/$maverickVersion}"
config="${config/'{MAVERICK_REGISTRY}'/$MAVERICK_REGISTRY}"
echo "$config" > $wd/.tools/docker-compose.yml

docker pull "$MAVERICK_REGISTRY:$maverickVersion"

docker compose -f .tools/docker-compose.yml up --build -d
