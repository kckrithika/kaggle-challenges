local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";

{
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "istio-pilot-service-account",
    namespace: "service-mesh",
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: istioUtils.istioLabels,
  },
}
