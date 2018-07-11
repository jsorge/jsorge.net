#! /usr/bin/env bash

# verify that it's not installed

wd=$(pwd)

# install
cd .tools
mkdir vendor
cd vendor
git clone https://github.com/olipo186/Git-Auto-Deploy.git
sudo apt-get install python-pip
sudo pip install -r requirements.txt

# copy config
sudo cp $(wd)/gitautodeploy.config.json config.json

# start the thing
python -m gitautodeploy --config config.json