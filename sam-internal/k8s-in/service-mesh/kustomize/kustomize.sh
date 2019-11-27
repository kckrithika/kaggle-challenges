#!/usr/bin/env bash

KUSTOMIZE_DIR=${KUSTOMIZE_DIR:-${BASH_SOURCE%/*}}

# Run kustomize build.
kustomize build ${KUSTOMIZE_DIR}/overlays/istio-init/ -o ${KUSTOMIZE_DIR}/istio-init.yaml
kustomize build ${KUSTOMIZE_DIR}/overlays/istio/ -o ${KUSTOMIZE_DIR}/istio.yaml

