#!/bin/bash
#Run this script by running validate.sh in the root dir

set -e
SAMTOOLS=ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/jiayi.yan/sam-tools:20170523_151602.44aa6930.clean.jiayiyan-ltm0

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
