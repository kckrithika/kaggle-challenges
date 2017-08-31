#!/bin/bash -ex

# Stop execution on first error
set -ex

# Use this to get hypersam env var
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../hypersam.sh"

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

time ./parallel_build.py templates-sam/,templates-sdn/,templates-slb/,templates-storage/ ../k8s-out/ ../pools/

# Json is quite poor when it comes to multi-line strings.  Since configMaps are a kubernetes resource with files
# encoded as strings within that file, you end up with generated configMaps with enormous lines that are hard to read 
# or review.
# This tool converts everything to yaml, and for configMaps it pretty prints the inner config entries

if [ -z "$GO_PIPELINE_LABEL" ]; then
  docker run --rm -v ${PWD}/../../:/repo ${HYPERSAM} /sam/manifestctl kube-json-to-yaml --in /repo/sam-internal/k8s-out/prd/prd-samtest/ --rm
  docker run --rm -v ${PWD}/../../:/repo ${HYPERSAM} /sam/manifestctl kube-json-to-yaml --in /repo/sam-internal/k8s-out/prd/prd-samdev/ --rm
else
  /opt/sam/manifestctl kube-json-to-yaml --in ../k8s-out/prd/prd-samtest/ --rm
  /opt/sam/manifestctl kube-json-to-yaml --in ../k8s-out/prd/prd-samdev/ --rm
fi

# TODO: Add warning when running against out-of-sync git repo

# TODO: Add some basic validations
