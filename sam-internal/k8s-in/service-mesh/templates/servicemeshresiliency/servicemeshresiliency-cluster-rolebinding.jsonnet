local configs = import "config.jsonnet";
local meshfeatureflags = import "mesh-feature-flags.jsonnet";

if meshfeatureflags.servicemeshResiliency then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRoleBinding",
  metadata: {
    name: "servicemeshresiliency",
    namespace: "service-mesh",
  },
  roleRef: {
    apiGroup: "rbac.authorization.k8s.io",
    kind: "ClusterRole",
    name: "servicemeshresiliency",
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "servicemeshresiliency",
      namespace: "service-mesh",
    },
  ],
} else "SKIP"
