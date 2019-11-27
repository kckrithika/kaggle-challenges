#!/usr/bin/env bash

TMP_DIR=${BASH_SOURCE%/*}/kustomize/

# Clone istio helm charts repo to tmp directory.
git clone --depth=1 --branch=master https://git.soma.salesforce.com/servicemesh/istio-helm-charts ${BASH_SOURCE%/*}/kustomize/tmp
rm -rf ${BASH_SOURCE%/*}/kustomize/tmp/.git

# Base directory for original helm generated manifests.
mkdir -p ${BASH_SOURCE%/*}/kustomize/base

# Clear out templates from base if they exist.
rm -rf ${BASH_SOURCE%/*}/kustomize/base/*/charts
rm -rf ${BASH_SOURCE%/*}/kustomize/base/*/templates

# Generate istio-init manifests.
helm template \
--output-dir ${BASH_SOURCE%/*}/kustomize/base \
--namespace mesh-control-plane \
--values ${BASH_SOURCE%/*}/kustomize/tmp/istio-init/sfdc-values/values.yaml  \
${BASH_SOURCE%/*}/kustomize/tmp/istio-init

## Multiple namespaces support is in helm 3 but we are using helm 2.
## So, till helm 3, we will run each namespace helm command separately.
# Generate pilot and sidecarInjectorWebhook manifests.
helm template istio \
--output-dir ${BASH_SOURCE%/*}/kustomize/base \
--namespace mesh-control-plane \
--values ${BASH_SOURCE%/*}/kustomize/tmp/istio/sfdc-values/values.yaml \
--set gateways.enabled=false \
--set global.proxy.envoyMetricsService.host=switchboard.service-mesh \
--set global.proxy.envoyMetricsService.tlsSettings.caCertificates=/client-certs/ca.pem \
--set global.proxy.envoyMetricsService.tlsSettings.clientCertificate=/client-certs/client/certificates/client.pem \
--set global.proxy.envoyMetricsService.tlsSettings.privateKey=/client-certs/client/keys/client-key.pem \
${BASH_SOURCE%/*}/kustomize/tmp/istio

# Generate gateways manifests in core-on-sam-sp2 namespace.
helm template istio \
--output-dir ${BASH_SOURCE%/*}/kustomize/base \
--namespace core-on-sam-sp2 \
--values ${BASH_SOURCE%/*}/kustomize/tmp/istio/sfdc-values/values.yaml \
--set pilot.enabled=false \
--set sidecarInjectorWebhook.enabled=false \
--set global.omitSidecarInjectorConfigMap=true \
--set global.proxy.envoyMetricsService.host=switchboard.service-mesh \
--set global.proxy.envoyMetricsService.tlsSettings.caCertificates=/client-certs/ca.pem \
--set global.proxy.envoyMetricsService.tlsSettings.clientCertificate=/client-certs/client/certificates/client.pem \
--set global.proxy.envoyMetricsService.tlsSettings.privateKey=/client-certs/client/keys/client-key.pem \
${BASH_SOURCE%/*}/kustomize/tmp/istio

# Delete tmp directory
rm -rf tmp/

./kustomize.sh

# Replace ship generated yamls with kustomize ones.
#cp istio-init.yaml ././../istio-init-ship/rendered.yaml
#cp istio.yaml ././../istio-ship/rendered.yaml