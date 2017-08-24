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

# Json is quite poor when it comes to multi-line strings.  Since configMaps are a file in a string, using json
# results in output configMap files with crazy long lines that are hard to review.
# This tool converts everything to yaml, and for configMaps it pretty prints the inner config entries

# TODO: Uncomment after updating rpm
#if [ -z "$GO_PIPELINE_LABEL" ]; then
#  docker run --rm -it -v ${PWD}/../../:/repo ${HYPERSAM} /sam/manifestctl kube-json-to-yaml --in /repo/sam-internal/k8s-out/prd/prd-samtest/ --rm
#else
#  /opt/sam/manifestctl jube-json-to-yaml
#fi

# TODO: Add warning when running against out-of-sync git repo

# TODO: Add some basic validations
