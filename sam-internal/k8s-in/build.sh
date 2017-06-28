#!/bin/bash

# Stop execution on first error
set -e

# Script to generate yaml files for all our apps in all estates
# ./build.sh


#Check if jsonnet is available, if not get it.
if [ ! -f jsonnet/jsonnet ]; then
    echo "Getting jsonnet..."
    git clone git@git.soma.salesforce.com:sam/jsonnet.git
    pushd jsonnet
    make
    popd
fi

rm -rf ../k8s-out/**
mkdir -p ../k8s-out/

time ./parallel_build.py templates/ ../k8s-out/ control-estates.txt

# TODO: Add warning when running against out-of-sync git repo

# TODO: Add some basic validations
