#!/bin/sh
set -e

# Assuming arguments for lndhub
if [ $(echo "$1" | cut -c1) = "-" ]; then
  exec "/usr/local/bin/npm start --prefix /lndhub $@"
else
  # lndhub standard launch with or without params
  if [ "$1" = "/usr/local/bin/npm start --prefix /lndhub" ]; then
    exec "$@"
  else
    # Custom launch
    exec "$@"
  fi
fi
