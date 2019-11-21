#!/usr/bin/env bash

# Clone istio helm charts repo to tmp directory.
git clone --depth=1 --branch=master https://git.soma.salesforce.com/servicemesh/istio-helm-charts tmp
rm -rf tmp/.git

# Base directory for original helm generated manifests.
mkdir -p base

# Clear out templates from base if they exist.
rm -rf base/*/charts
rm -rf base/*/templates

# Generate istio-init manifests.
helm template \
--output-dir base \
--namespace mesh-control-plane \
--values tmp/istio-init/sfdc-values/values.yaml  \
tmp/istio-init

## Multiple namespaces support is in helm 3 but we are using helm 2.
## So, till helm 3, we will run each namespace helm command separately.
# Generate gateways manifests in core-on-sam-sp2 namespace.
helm template istio \
--output-dir base \
--namespace core-on-sam-sp2 \
--values tmp/istio/sfdc-values/values.yaml \
--set pilot.enabled=false \
--set sidecarInjectorWebhook.enabled=false \
--set global.omitSidecarInjectorConfigMap=true \
tmp/istio

# Generate pilot and sidecarInjectorWebhook manifests.
helm template istio \
--output-dir base \
--namespace mesh-control-plane \
--values tmp/istio/sfdc-values/values.yaml \
--set gateways.enabled=false \
tmp/istio

# Delete tmp directory
rm -rf tmp/

./kustomize.sh

# Replace ship generated yamls with kustomize ones.
#cp istio-init.yaml ././../istio-init-ship/rendered.yaml
#cp istio.yaml ././../istio-ship/rendered.yaml