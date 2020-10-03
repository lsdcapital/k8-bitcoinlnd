#!/bin/bash

# Helper podman build script

read -p "Enter new upstream version (no input to build current): " VERSION

if [[ -z $VERSION ]]; then
    VERSION=$(grep -m1 "APP_VERSION" Dockerfile |cut -f2 -d\")
else
    sed -i -E "0,/APP_VERSION/s/APP_VERSION.*/APP_VERSION \"$VERSION\"/" Dockerfile
fi

echo "Building $VERSION"
podman build -f Dockerfile -t docker.io/lsdopen/lnd:$VERSION

echo "If this was successful, ensure you are logged into your image repo (podman login) and podman push repo/lnd:$VERSION"