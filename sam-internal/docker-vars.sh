#!/bin/env bash

# Set pip cache based on platform, set mount flag for MacOS
# The :delegated flag batches up FS calls from the container VM to the host filesystem,
# dramatically improving performance of file operations within bind mounts.
# See https://docs.docker.com/docker-for-mac/osxfs-caching/ for more info.
if [[ "$(uname)" == "Darwin" ]]; then
    BIND_MOUNT_OPTIONS=":delegated"
    CACHE_DIR="${HOME}/Library/Caches"
else
    BIND_MOUNT_OPTIONS=""
    CACHE_DIR="${HOME}/.cache"
fi
