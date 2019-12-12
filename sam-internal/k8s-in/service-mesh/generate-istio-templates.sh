#!/usr/bin/env bash

# Prepare directories for volume mounts.
rm -rf /tmp/istio-upgrade

mkdir -p /tmp/istio-upgrade/istio-init
mkdir -p /tmp/istio-upgrade/istio
mkdir -p /tmp/istio-upgrade/templates

# Copy generated istio-init `rendered.yaml` to /tmp/istio-upgrade/istio-init directory.
#cp ${BASH_SOURCE%/*}/istio-init-ship/rendered.yaml /tmp/istio-upgrade/istio-init/
cp ${BASH_SOURCE%/*}/kustomize/istio-init.yaml /tmp/istio-upgrade/istio-init/rendered.yaml

# Copy generated istio `rendered.yaml` to /tmp/istio-upgrade/istio directory.
#cp ${BASH_SOURCE%/*}/istio-ship/rendered.yaml /tmp/istio-upgrade/istio/
cp ${BASH_SOURCE%/*}/kustomize/istio.yaml /tmp/istio-upgrade/istio/rendered.yaml

# Run tool to convert yaml to jsonnet templates.
#docker pull ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/servicemesh/istio-upgrade:dev

# Generate istio-init jsonnets.
docker run \
  -v /tmp/istio-upgrade/istio-init:/istio-ship \
  -v /tmp/istio-upgrade/templates:/templates \
  istio-upgrade:dev \
  /

# Move istio-init templates.
rm ${BASH_SOURCE%/*}/templates/istio/phase1/istio-init-autogenerated/*.jsonnet
mv /tmp/istio-upgrade/templates/* ${BASH_SOURCE%/*}/templates/istio/phase1/istio-init-autogenerated/

# Generate istio jsonnets.
docker run \
  -v /tmp/istio-upgrade/istio:/istio-ship \
  -v /tmp/istio-upgrade/templates:/templates \
  istio-upgrade:dev \
  /

# Move istio templates.
rm ${BASH_SOURCE%/*}/templates/istio/phase1/istio-autogenerated/*.jsonnet
mv /tmp/istio-upgrade/templates/* ${BASH_SOURCE%/*}/templates/istio/phase1/istio-autogenerated/

# Format auto-generated jsonnets.
${BASH_SOURCE%/*}/../jsonnet/jsonnet fmt -i ${BASH_SOURCE%/*}/templates/istio/phase1/istio-init-autogenerated/*.*sonnet
${BASH_SOURCE%/*}/../jsonnet/jsonnet fmt -i ${BASH_SOURCE%/*}/templates/istio/phase1/istio-autogenerated/*.*sonnet

# Move istio-ingressgateway templates to a separate directory.
mv ${BASH_SOURCE%/*}/templates/istio/phase1/istio-autogenerated/*ingressgateway* \
  ${BASH_SOURCE%/*}/templates/istio/phase1/istio-ingressgateway-autogenerated/

# Remove tmp.
rm -rf /tmp/istio-upgrade
