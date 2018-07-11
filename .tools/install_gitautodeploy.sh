#! /usr/bin/env bash

# verify that it's not installed

# install
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:olipo186/git-auto-deploy
sudo apt-get update
sudo apt-get install git-auto-deploy

# copy config
sudo cp gitautodeploy.config.json /etc/git-auto-deploy.conf.json
sudo chown git-auto-deploy /etc/git-auto-deploy.conf.json

# copy ssh keys
sudo cp ~/.ssh/id_rsa /etc/git-auto-deploy/.ssh/
sudo chown -R git-auto-deploy:git-auto-deploy /etc/git-auto-deploy

# make new user group that allows pulling
sudo groupadd maverick

# add the current user, git-auto-deploy, and root to the group
sudo usermod -a -G maverick git-auto-deploy
sudo usermod -a -G maverick $USER

# make the group the owner of the working directory
sudo chgrp -R maverick .
sudo chmod -R g+swX .

service git-auto-deploy start
service git-auto-deploy status