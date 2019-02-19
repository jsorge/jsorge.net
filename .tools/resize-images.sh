#! /usr/bin/env bash

# pre-commit.sh
STASH_NAME="pre-commit-$(date +%s)"
git stash save -q --keep-index $STASH_NAME

# TODO: Work through png and jpgs
magick mogrify -resize 500">" *.jpg

git add .

STASHES=$(git stash list)
if [[ $STASHES == "$STASH_NAME" ]]; then
  git stash pop -q
fi
