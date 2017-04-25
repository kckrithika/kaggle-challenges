#!/bin/bash

SAMTOOLS=ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/prahlad.joshi/sam-tools:20170425_124235.c332148.clean.prahladjos-ltm

set -e

echo "NOTE: If the docker run command returns a 'BAD_CREDENTIAL' error, you need to run 'docker login ops0-artifactrepo1-0-prd.data.sfdc.net' (one-time). See https://confluence.internal.salesforce.com/x/NRDa (Set up Docker for Sam)"

EXTRAARGS=""

if [ "$1" == "verbose" ]
then
  EXTRAARGS="-verbose"
fi

docker run \
  --rm \
  -it \
  -u 0 \
  -v ${PWD}:/repo \
  ${SAMTOOLS} \
  sam-manifest-builder \
  --root='/repo/' \
  -validateonly \
  $EXTRAARGS
