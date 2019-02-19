#!/bin/sh

BASE_VERSION=7.0.8-27
WHICH_CMD=`which magick`
MISSING_MSG="warning: ImageMagick not installed. Please install using brew."
UPGRADE_MSG="warning: ImageMagick requires a newer version. Please upgrade using brew."

function version_gt() { test $(printf '%s\n' "$@" | sort --version-sort | head -n 1) != "${1}"; }

if [ ! -f "${WHICH_CMD}" ]; then
  echo $MISSING_MSG
else
  MAGICK_VERSION=`"${WHICH_CMD}" --version`
    if version_gt ${MAGICK_VERSION} ${BASE_VERSION}; then
    exit
  else
    echo $UPGRADE_MSG
  fi
fi
