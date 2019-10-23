#!/bin/bash -ex

# Stop execution on first error
set -ex

if [ "$1" == "-h" ]; then
  echo "Usage: build.sh - with no arguments processes all kingdoms and estates"
  echo "       build.sh \"kingdom/estate1,kingdom/*foo*,*bar*\" - processes a set of estates supporting wildcard!"
  exit 1
fi

# Use this to get hypersam env var
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../hypersam.sh"

# Get docker vars
. "$DIR/../docker-vars.sh"

cd $DIR

# Script to generate yaml files for all our apps in all estates
# ./build.sh

if [ -z "$FIREFLY" ]; then
   SAMBINDIR=/opt/sam
else
   echo "*** EXECUTING IN $FIREFLY ENVIRONMENT"
   SAMBINDIR=/sam
fi

# Populate dir to cache jsonnet executable if not present
JSONNET_EXEC_CACHE_DIR="${CACHE_DIR}/jsonnet_exec"
JSONNET_EXEC_DIR="jsonnet"

if [ ! -d ${JSONNET_EXEC_CACHE_DIR} ]; then
    mkdir -p ${JSONNET_EXEC_CACHE_DIR}
fi

# Look for jsonnet in exec cache if not found here, copy over to avoid need to recompile
if [ ! -f ${JSONNET_EXEC_DIR}/jsonnet ] && [ -f "${JSONNET_EXEC_CACHE_DIR}/jsonnet" ]; then
    if [ ! -f ${JSONNET_EXEC_DIR} ]; then
        mkdir -p ${JSONNET_EXEC_DIR}
    fi
    cp ${JSONNET_EXEC_CACHE_DIR}/jsonnet ${JSONNET_EXEC_DIR}/jsonnet
fi

# Make sure we are on the right version of jsonnet (0.9.5 needed for fmt)
# If we use an older verion of jsonnet the script will fail.
EXPECTED_JSONNET_VER="Jsonnet commandline interpreter v0.9.5"
if [ -f ${JSONNET_EXEC_DIR}/jsonnet ]; then
  ACTUAL_JSONNET_VER=$(${JSONNET_EXEC_DIR}/jsonnet -version || true)
  echo "Running jsonnet version '$ACTUAL_JSONNET_VER'."
  if [[ "$EXPECTED_JSONNET_VER" != "$ACTUAL_JSONNET_VER" ]]; then
    echo "Local jsonnet is not expected version '$EXPECTED_JSONNET_VER'.  Deleting folder."
    rm -rf ${JSONNET_EXEC_DIR}
  fi
fi

#Check if jsonnet is available, if not get it.
if [ ! -f jsonnet/jsonnet ]; then
    echo "Getting jsonnet..."
    git clone git@git.soma.salesforce.com:sam/jsonnet.git
    pushd jsonnet
    # Pin to version 0.95 so we can update the repo and have stable build while we test the new version
    git checkout 6b7f64c136156ca67371be6089d2b89d5f0dab9e
    make
    cp jsonnet ${JSONNET_EXEC_CACHE_DIR}/jsonnet
    popd
fi

# Nuke output folder to ensure we don't keep around stale output files
if [ "$1" == "" ]; then
  rm -rf ../k8s-out/**
  mkdir -p ../k8s-out/
  cp k8s-out-access.yaml ../k8s-out/access.yaml
else
  echo "Skipping cleanup because we are processing a filtered list of estates"
fi


# Format input jsonnet files.  TODO: Auto-compute these directories
for jdir in . sam sam/configs sam/templates sam/templates/rbac sdn sdn/templates secrets secrets/templates slb slb/templates flowsnake flowsnake/templates sfcd sfcd/templates tnrp tnrp/templates service-mesh service-mesh/templates service-mesh/namespaces/templates service-mesh/sherpa-injector/templates service-mesh/switchboard/templates service-mesh/zoobernetes/templates dva-collection dva-collection/templates topology-svc/templates authz/templates stampy/templates; do
  # We want to format both *.jsonnet and *.libsonnet.  Doing this with a wildcard is a little ugly, but we cant do it with 2 commands because the command will fail if any directory has one type of file but not the other
  jsonnet/jsonnet fmt -i $jdir/*.*sonnet
done

if [ -z "$GO_PIPELINE_LABEL" ]; then
  docker run -u 0 --rm -v ${PWD}/../../:/repo${BIND_MOUNT_OPTIONS} ${HYPERSAM} /sam/manifestctl generate-pool-list --in /repo/sam-internal/pools/ --out  /repo/sam-internal/k8s-in/sam/configs/generated-pools.jsonnet
else
  ${SAMBINDIR}/manifestctl generate-pool-list --in ../pools/ --out  ../k8s-in/sam/configs/generated-pools.jsonnet
fi

./parallel_build.py --src=sam/templates/,sdn/templates/,secrets/templates/,slb/templates/,tnrp/templates,dva-collection/templates,topology-svc/templates,service-mesh/templates,service-mesh/namespaces/templates,service-mesh/sherpa-injector/templates,service-mesh/switchboard/templates,service-mesh/zoobernetes/templates,casam/templates,authz/templates,stampy/templates  --out=../k8s-out/ --pools=../pools/ --estatefilter=$1 --labelfilterfile=samlabelfilter.json

./parallel_build.py --src=flowsnake/templates,sdn/templates --out=../k8s-out/ --pools=flowsnake/flowsnakeEstates.json --estatefilter=$1
# Skip SDN templates for Minikube
./parallel_build.py --src=flowsnake/templates --out=../k8s-out/ --pools=flowsnake/flowsnakeMinikubeEstates.json --estatefilter=$1

./parallel_build.py --src=sam/templates/,slb/templates/ --out=../k8s-out/ --pools=vpod/vpodEstates.json --estatefilter=$1

# Json is quite poor when it comes to multi-line strings.  Since configMaps are a kubernetes resource with files
# encoded as strings within that file, you end up with generated configMaps with enormous lines that are hard to read
# or review.
# This tool converts everything to yaml, and for configMaps it pretty prints the inner config entries

if [ -z "$GO_PIPELINE_LABEL" ]; then
  docker run -u 0 --rm -v ${PWD}/../../:/repo${BIND_MOUNT_OPTIONS} ${HYPERSAM} /sam/manifestctl kube-json-to-yaml --in /repo/sam-internal/k8s-out/ --rm
else
  ${SAMBINDIR}/manifestctl kube-json-to-yaml --in ../k8s-out/ --rm
fi

# Validate configMaps

if [ -z "$GO_PIPELINE_LABEL" ]; then
  docker run -u 0 --rm -v ${PWD}/../../:/repo${BIND_MOUNT_OPTIONS} ${HYPERSAM} /sam/manifestctl validate-k8s -per-kingdom-dir-list /repo/sam-internal/k8s-out/ -verbose
else
  ${SAMBINDIR}/manifestctl validate-k8s -per-kingdom-dir-list ../k8s-out/ -verbose
fi

# evaluate_pr2 has a check that all files in k8s-in/k8s-out match, and it does not read .gitignore
# Until that script is fixed we need to remove this at the end
rm -rf multifile-temp/

# TODO: Add warning when running against out-of-sync git repo

# TODO: Add some basic validations
