#!/usr/bin/env bash

echo ${KUSTOMIZE_DIR}

KUSTOMIZE_DIR=${KUSTOMIZE_DIR:-${BASH_SOURCE%/*}/kustomize/}

echo ${KUSTOMIZE_DIR}

# Run kustomize build.
kustomize build ${KUSTOMIZE_DIR}/overlays/istio-init/ -o ${KUSTOMIZE_DIR}/istio-init.yaml
kustomize build ${KUSTOMIZE_DIR}/overlays/istio/ -o ${KUSTOMIZE_DIR}/istio.yaml

