local configs = import "config.jsonnet";
local meshfeatureflags = import "mesh-feature-flags.jsonnet";

if meshfeatureflags.servicemeshResiliency then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "servicemeshresiliency",
    namespace: "service-mesh",
  },
  rules: [
    {
      apiGroups: ["extensions"],
      resources: [
        "deployments",
      ],
      verbs: ["get", "list", "watch", "create", "update", "patch", "delete"],
    },
  ],
} else "SKIP"