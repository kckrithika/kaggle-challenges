#!/usr/bin/env bash

KUSTOMIZE_DIR=${BASH_SOURCE%/*}/kustomize
TMP_DIR=${KUSTOMIZE_DIR}/tmp

# Clone istio helm charts repo to tmp directory.
git clone --depth=1 --branch=master git@git.soma.salesforce.com:servicemesh/istio-helm-charts.git ${TMP_DIR}
rm -rf ${TMP_DIR}/.git

# Base directory for original helm generated manifests.
mkdir -p ${KUSTOMIZE_DIR}/base

# Clear out templates from base if they exist.
rm -rf ${KUSTOMIZE_DIR}/base/*/charts
rm -rf ${KUSTOMIZE_DIR}/base/*/templates

# Generate istio-init manifests.
helm template \
--output-dir ${KUSTOMIZE_DIR}/base \
--namespace mesh-control-plane \
--values ${TMP_DIR}/istio-init/sfdc-values/values.yaml  \
${TMP_DIR}/istio-init

## Multiple namespaces support is in helm 3 but we are using helm 2.
## So, till helm 3, we will run each namespace helm command separately.
# Generate pilot and sidecarInjectorWebhook manifests.
helm template istio \
--output-dir ${KUSTOMIZE_DIR}/base \
--namespace mesh-control-plane \
--values ${TMP_DIR}/istio/sfdc-values/values.yaml \
--set gateways.enabled=false \
--set global.proxy.envoyMetricsService.host=switchboard.service-mesh \
--set global.proxy.envoyMetricsService.tlsSettings.caCertificates=/client-certs/ca.pem \
--set global.proxy.envoyMetricsService.tlsSettings.clientCertificate=/client-certs/client/certificates/client.pem \
--set global.proxy.envoyMetricsService.tlsSettings.privateKey=/client-certs/client/keys/client-key.pem \
${TMP_DIR}/istio

# Generate gateways manifests in core-on-sam-sp2 namespace.
helm template istio \
--output-dir ${KUSTOMIZE_DIR}/base \
--namespace core-on-sam-sp2 \
--values ${TMP_DIR}/istio/sfdc-values/values.yaml \
--set pilot.enabled=false \
--set sidecarInjectorWebhook.enabled=false \
--set global.omitSidecarInjectorConfigMap=true \
--set global.proxy.envoyMetricsService.host=switchboard.service-mesh \
--set global.proxy.envoyMetricsService.tlsSettings.caCertificates=/client-certs/ca.pem \
--set global.proxy.envoyMetricsService.tlsSettings.clientCertificate=/client-certs/client/certificates/client.pem \
--set global.proxy.envoyMetricsService.tlsSettings.privateKey=/client-certs/client/keys/client-key.pem \
${TMP_DIR}/istio

# Delete tmp directory.
rm -rf ${TMP_DIR}/

# Sourcing the kustomize script so that it uses the KUSTOMIZE_DIR initialized here.
. ${KUSTOMIZE_DIR}/kustomize.sh
