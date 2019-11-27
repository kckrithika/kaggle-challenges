#!/usr/bin/env bash

# Run kustomize build.
kustomize build ${BASH_SOURCE%/*}/kustomize/overlays/istio-init/ -o istio-init.yaml
kustomize build ${BASH_SOURCE%/*}/kustomize/overlays/istio/ -o istio.yaml

