#!/bin/sh
set -e

# Assuming arguments for lndhub
if [ $(echo "$1" | cut -c1) = "-" ]; then
  exec lnd "$@"
else
  # lndhub / lncli standard launch with or without params
  if [ "$1" = "lnd" ] || [ "$1" = "lncli" ]; then
    exec "$@"
  else
    # Custom launch
    exec "$@"
  fi
fi
