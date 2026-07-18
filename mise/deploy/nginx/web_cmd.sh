#!/usr/bin/env bash

# Start Nginx in foreground so Docker container doesn't exit
nginx -g "daemon off;"
