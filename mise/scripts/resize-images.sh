#!/usr/bin/env bash

set -e
set -o pipefail

# Ensure swift-sh is installed
./tools/ensure-swift-sh.sh

# Check for ImageMagick
./.tools/ensure-imagemagick.sh

# Run the resize script
./vendor/swift-sh ./.tools/ResizeImages.swift
