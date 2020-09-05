#!/bin/sh
set -e

# Assuming arguments for lnd
if [ $(echo "$1" | cut -c1) = "-" ]; then
  exec lnd "$@"
else
  # lnd / lncli standard launch with or without params
  if [ "$1" = "lnd" ] || [ "$1" = "lncli" ]; then
    exec "$@"
  else
    # Custom launch
    exec "$@"
  fi
fi
