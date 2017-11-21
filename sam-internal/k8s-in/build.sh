#!/bin/bash -ex

# Stop execution on first error
set -ex

# Use this to get hypersam env var
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../hypersam.sh"

# Script to generate yaml files for all our apps in all estates
# ./build.sh

# Make sure we are on the right version of jsonnet (0.9.5 needed for fmt)
# If we use an older verion of jsonnet the script will fail.
EXPECTED_JSONNET_VER="Jsonnet commandline interpreter v0.9.5"
if [ -f jsonnet/jsonnet ]; then
  ACTUAL_JSONNET_VER=$(jsonnet/jsonnet -version || true)
  echo "Running jsonnet version '$ACTUAL_JSONNET_VER'."
  if [[ "$EXPECTED_JSONNET_VER" != "$ACTUAL_JSONNET_VER" ]]; then
    echo "Local jsonnet is not expected version '$EXPECTED_JSONNET_VER'.  Deleting folder."
    rm -rf jsonnet/
  fi
fi

#Check if jsonnet is available, if not get it.
if [ ! -f jsonnet/jsonnet ]; then
    echo "Getting jsonnet..."
    git clone git@git.soma.salesforce.com:sam/jsonnet.git
    pushd jsonnet
    make
    popd
fi

# Nuke output folder to ensure we dont keep around stale output files
rm -rf ../k8s-out/**
mkdir -p ../k8s-out/
cp k8s-out-access.yaml ../k8s-out/access.yaml

# Format input jsonnet files.  TODO: Auto-compute these directories
for jdir in . sam sam/configs sam/templates sam/templates/rbac sdn sdn/templates slb slb/templates storage/templates; do
  jsonnet/jsonnet fmt -i $jdir/*.jsonnet
done

if [ -z "$GO_PIPELINE_LABEL" ]; then
  docker run -u 0 --rm -v ${PWD}/../../:/repo ${HYPERSAM} /sam/manifestctl generate-pool-list --in /repo/sam-internal/pools/ --out  /repo/sam-internal/k8s-in/sam/configs/generated-pools.jsonnet
else
  /opt/sam/manifestctl generate-pool-list --in ../pools/ --out  ../k8s-in/sam/configs/generated-pools.jsonnet
fi

time ./parallel_build.py sam/templates/,sdn/templates/,slb/templates/,storage/templates/ ../k8s-out/ ../pools/
time ./parallel_build.py flowsnake/templates,sdn/templates ../k8s-out/ flowsnakeEstates.json

# Json is quite poor when it comes to multi-line strings.  Since configMaps are a kubernetes resource with files
# encoded as strings within that file, you end up with generated configMaps with enormous lines that are hard to read
# or review.
# This tool converts everything to yaml, and for configMaps it pretty prints the inner config entries

if [ -z "$GO_PIPELINE_LABEL" ]; then
  docker run -u 0 --rm -v ${PWD}/../../:/repo ${HYPERSAM} /sam/manifestctl kube-json-to-yaml --in /repo/sam-internal/k8s-out/ --rm
else
  /opt/sam/manifestctl kube-json-to-yaml --in ../k8s-out/ --rm
fi

# Validate configMaps

if [ -z "$GO_PIPELINE_LABEL" ]; then
  docker run -u 0 --rm -v ${PWD}/../../:/repo ${HYPERSAM} /sam/manifestctl validate-config-maps --in /repo/sam-internal/k8s-out/
else
  /opt/sam/manifestctl validate-config-maps --in ../k8s-out/
fi

# TODO: Add warning when running against out-of-sync git repo

# TODO: Add some basic validations
