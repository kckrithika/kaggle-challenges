local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.sloop then {
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "sloop",
    namespace: "sam-system",
  },
} else "SKIP"
