#!/usr/bin/env bash

# Clone istio helm charts repo to tmp directory.
git clone --depth=1 --branch=master https://git.soma.salesforce.com/servicemesh/istio-helm-charts tmp
rm -rf tmp/.git

# Base directory for original helm generated manifests.
mkdir -p base

# Generate istio-init manifests.
helm template \
--output-dir base \
--namespace mesh-control-plane \
--values tmp/istio-init/sfdc-values/values.yaml  \
tmp/istio-init

# TODO: Make createServiceAccount configurable at global level, or move it to a separate file sfdc-values/values-falcon.yaml
# Generate pilot and sidecarInjectorWebhook manifests.
# Multiple namespaces support is getting added in helm 3. So, till that time we will run each namespace helm command separately.
helm template \
--output-dir base \
--namespace mesh-control-plane \
--values tmp/istio/sfdc-values/values.yaml \
--set gateways.enabled=false \
--set createServiceAccount=true \
--set pilot.createServiceAccount=true \
--set sidecarInjectorWebhook.createServiceAccount=true \
--set gateways.istio-ingressgateway.createServiceAccount=true  \
tmp/istio

# Generate gateways in core-on-sam-sp2 namespace.
helm template \
--output-dir base \
--namespace core-on-sam-sp2 \
--values tmp/istio/sfdc-values/values.yaml \
--set pilot.enabled=false \
--set sidecarInjectorWebhook.enabled=false \
--set createServiceAccount=true \
--set gateways.istio-ingressgateway.createServiceAccount=true  \
--set global.omitSidecarInjectorConfigMap=true \
tmp/istio

# Delete tmp directory
rm -rf tmp/
