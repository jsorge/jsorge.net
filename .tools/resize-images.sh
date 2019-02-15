#! /usr/bin/env bash

CURRENT_DIR=$(pwd)
cd ~/Downloads

# TODO: Work through png and jpgs

magick mogrify -resize 300">" *.jpg

cd $CURRENT_DIR
