#!/bin/bash
#Run this script by running validate.sh in the root dir

set -e
SAMTOOLS=ops0-artifactrepo1-0-prd.data.sfdc.net/tnrp/sam/hypersam:sam-0000943-121335be

echo "NOTE: If the docker run command returns a 'BAD_CREDENTIAL' error, you need to run 'docker login ops0-artifactrepo1-0-prd.data.sfdc.net' (one-time). See https://confluence.internal.salesforce.com/x/NRDa (Set up Docker for Sam)"

docker run \
  --rm \
  -it \
  -u 0 \
  -v ${PWD}:/repo \
  ${SAMTOOLS} \
  sam-manifest-builder \
  --root='/repo/' \
  --swaggerspecdir='/sam/swagger-spec' \
  -validateonly \
  -validationExceptionsFile=/repo/sam-internal/validation-whitelist.yaml
