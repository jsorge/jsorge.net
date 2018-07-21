#! /usr/bin/env bash
source .tools/parse_yaml.sh

# verify that it's not installed
if [ -d ".tools/vendor/Git-Auto-Deploy" ]; then
  exit 0
fi

# setup variables
wd=$(pwd)
siteConfigPath="$wd/SiteConfig.yml"
template="$wd/.tools/templates/gitautodeploy.config_template.json"

# install
cd .tools

if [ ! -d "vendor" ]; then
	mkdir vendor
fi

cd vendor
git clone https://github.com/olipo186/Git-Auto-Deploy.git
cd Git-Auto-Deploy
sudo -H apt-get install python-pip
sudo -H pip install -r requirements.txt

# copy config
eval $(parse_yaml $siteConfigPath)
config=$(cat $template)
config="${config/'{REPO_URL}'/$autodeploy_url}"
config="${config/'{SITE_DIRECTORY}'/$autodeploy_directory}"
echo "$config" > config.json

# start the thing
python -m gitautodeploy --daemon-mode --config config.json