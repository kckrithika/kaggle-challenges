local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";

if configs.estate == "prd-samtest" then {
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "istio-pilot-service-account",
    namespace: "service-mesh",
    labels: istioUtils.istioLabels,
  },
} else "SKIP"
