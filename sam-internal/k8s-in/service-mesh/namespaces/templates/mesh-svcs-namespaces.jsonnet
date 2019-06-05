# istio-inject: enabled enables both the webhooks - istio-sidecar-injector & istio-routing-webhook
local utils = import "util_functions.jsonnet";
local configs = import "config.jsonnet";
local mesh_namespaces = ["app", "service-mesh", "gater", "ccait", "core-on-sam-sp2", "core-on-sam", "casam", "emailinfra", "universal-search", "search-scale-safely"];
{
  apiVersion: "v1",
  metadata: {
    labels: {} +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
  },
  items: [
    {
      apiVersion: "v1",
      kind: "Namespace",
      metadata: {
        labels: {
          "istio-injection": "enabled",
        } + (if namespace == "service-mesh" then
          { "sherpa-injection": "enabled" } else {})
        +
        // samlabelfilter.json requires this label to be present on GCP deployments
        if utils.is_pcn(configs.kingdom) && namespace == "service-mesh" then configs.pcnEnableLabel else {},
        name: namespace,
      },
    }
    for namespace in mesh_namespaces
  ],
  kind: "List",
}
