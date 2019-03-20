#!/usr/bin/env bash

# Prepare directories for volume mounts.
rm -rf /tmp/istio-upgrade
mkdir -p /tmp/istio-upgrade/istio-ship
mkdir -p /tmp/istio-upgrade/templates
cp ${BASH_SOURCE%/*}/istio-ship/rendered.yaml /tmp/istio-upgrade/istio-ship/

# Run tool to convert yaml to jsonnet templates.
docker pull ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/servicemesh/istio-upgrade:dev

docker run \
  -v /tmp/istio-upgrade/istio-ship:/istio-ship \
  -v /tmp/istio-upgrade/templates:/templates \
  ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/servicemesh/istio-upgrade:dev \
  /

# Copy the templates and clean-up tmp directory.
cp /tmp/istio-upgrade/templates/* ${BASH_SOURCE%/*}/templates/istio/
rm -rf /tmp/istio-upgrade
