#!/bin/sh
set -e

# Assuming arguments for lndhub
if [ $(echo "$1" | cut -c1) = "-" ]; then
  exec "node /lndhub/index.js $@"
else
  # lndhub standard launch with or without params
  if [ "$1" = "node /lndhub/index.js" ]; then
    exec "$@"
  else
    # Custom launch
    exec "$@"
  fi
fi
