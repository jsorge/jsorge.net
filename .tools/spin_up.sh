#! /usr/bin/env bash
source .tools/parse_yaml.sh

docker pull jsorge/maverick:latest

# setup variables
wd=$(pwd)
siteConfigPath="$wd/SiteConfig.yml"
template="$wd/.tools/templates/docker-compose_template.yml"

# copy config
eval $(parse_yaml $siteConfigPath)
config=$(cat $template)
trimmedurl=$(echo "$url" | awk -F/ '{print $3}')
config="${config/'{CONFIG_DOMAIN}'/$trimmedurl}"
config="${config/'{CONFIG_EMAIL}'/$ssl_contactEmail}"
echo "$config" > $wd/.tools//docker-compose.yml

# start auto-deploy
make install-autodeploy

docker-compose -f .tools/docker-compose.yml up --build
