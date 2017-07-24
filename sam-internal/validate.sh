#!/bin/bash
#Run this script by running validate.sh in the root dir
#If you are updating sam-manifest-builder also update in tnrp/pipeline_manifest.json and follow all the steps
#here https://git.soma.salesforce.com/sam/sam/wiki/Update-SAM-Manifest-Builder

set -e
HYPERSAM=ops0-artifactrepo1-0-prd.data.sfdc.net/tnrp/sam/hypersam:sam-0001057-fe060a6d

echo "NOTE: If the docker run command returns a 'BAD_CREDENTIAL' error, you need to run 'docker login ops0-artifactrepo1-0-prd.data.sfdc.net' (one-time). See https://confluence.internal.salesforce.com/x/NRDa (Set up Docker for Sam)"

docker run \
  --rm \
  -it \
  -u 0 \
  -v ${PWD}:/repo \
  ${HYPERSAM} \
  sam-manifest-builder \
  --root='/repo/' \
  --swaggerspecdir='/sam/swagger-spec' \
  -validateonly \
  -validationExceptionsFile=/repo/sam-internal/validation-whitelist.yaml
