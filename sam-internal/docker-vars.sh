#!/bin/env bash

# Set pip cache based on platform, set mount flag for MacOS
# See https://docs.docker.com/docker-for-mac/osxfs-caching/ for info on :delegated flag.
if [[ "$(uname)" == "Darwin" ]]; then
    PIP_DOWNLOAD_CACHE="${HOME}/Library/Caches/pip"
    BIND_MOUNT_OPTIONS=":delegated"
else
    PIP_DOWNLOAD_CACHE="${HOME}/.cache/pip"
    BIND_MOUNT_OPTIONS=""
fi
PIP_CACHE_MOUNT="/tmp/caches/pip"
