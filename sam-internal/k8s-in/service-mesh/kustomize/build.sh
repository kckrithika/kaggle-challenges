#!/usr/bin/env bash

# Run kustomize build.
kustomize build overlays/istio-init/ -o istio-init.yaml
kustomize build overlays/istio/ -o istio.yaml

