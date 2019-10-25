#!/bin/bash
#Run this script by running validate.sh in the root dir
#If you are updating sam-manifest-builder also update in tnrp/pipeline_manifest.json and follow all the steps
#here https://git.soma.salesforce.com/sam/sam/wiki/Update-SAM-Manifest-Builder

set -e

# Use this to get hypersam env var
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/hypersam.sh"
. "$DIR/k8s-in/slb/slbmb.sh"

# Get docker-specific vars
. "$DIR/docker-vars.sh"

echo "NOTE: If the docker run command returns a 'BAD_CREDENTIAL' error, you need to run 'docker login ops0-artifactrepo1-0-prd.data.sfdc.net' (one-time). See https://confluence.internal.salesforce.com/x/NRDa (Set up Docker for Sam)"

docker run \
  --rm \
  -it \
  -u 0 \
  -v ${PWD}:/repo${BIND_MOUNT_OPTIONS} \
  ${HYPERSAM} \
  aclrepo -validateDir /repo/

docker run \
  --rm \
  -it \
  -u 0 \
  -v ${PWD}:/repo${BIND_MOUNT_OPTIONS} \
  ${HYPERSAM} \
  manifestctl validate-manifests \
  --inputDir='/repo/' \
  --validationExceptionsFile=/repo/sam-internal/validation-whitelist.yaml \
  -skipSamIntSwagger \
  -fullSchemaValidationEnabled \

docker run \
  --rm \
  -it \
  -u 0 \
  -v ${PWD}:/repo${BIND_MOUNT_OPTIONS} \
  --entrypoint /sdn/slb-manifest-builder \
  ${SLBMB} \
  --root='/repo/' \
  -output='/repo/' \
  -validate \



