#! /usr/bin/env bash

# verify that it's not installed

# install
cd .tools
git clone https://github.com/olipo186/Git-Auto-Deploy.git
curl https://bootstrap.pypa.io/get-pip.py | python
sudo pip install -r requirements.txt

# copy config
cd ..
sudo cp gitautodeploy.config.json /.tools/git-atuo-deploy/config.json
sudo chown git-auto-deploy /etc/git-auto-deploy.conf.json

# start the thing
python -m .tools/git-auto-deploy/gitautodeploy --config .tools/git-auto-deploy/config.json