local configs = import "config.jsonnet";
local meshfeatureflags = import "mesh-feature-flags.jsonnet";

if meshfeatureflags.servicemeshResiliency then {
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "servicemeshresiliency",
    namespace: "service-mesh",
  },
} else "SKIP"
