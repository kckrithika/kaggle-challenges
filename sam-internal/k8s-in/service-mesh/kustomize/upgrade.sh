#!/usr/bin/env bash

#!/usr/bin/env bash

# Clone istio helm charts repo.
git clone --depth=1 --branch=master https://git.soma.salesforce.com/servicemesh/istio-helm-charts tmp
rm -rf tmp/.git

# Generate manifest files from helm templates.
mkdir -p base
helm template \
--output-dir base \
--namespace mesh-control-plane \
--values tmp/istio-init/sfdc-values/values.yaml  \
tmp/istio-init

# TODO: Make createServiceAccount configurable at global level, or move it to a separate file sfdc-values/values-falcon.yaml
helm template \
--output-dir base \
--namespace mesh-control-plane \
--values tmp/istio/sfdc-values/values.yaml \
--set createServiceAccount=true \
--set pilot.createServiceAccount=true \
--set sidecarInjectorWebhook.createServiceAccount=true \
--set gateways.istio-ingressgateway.createServiceAccount=true  \
tmp/istio

# Delete tmp directory
rm -rf tmp/
