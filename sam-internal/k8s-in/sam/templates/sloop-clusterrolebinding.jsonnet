local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.sloop then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRoleBinding",
  metadata: {
    name: "sloop",
  },
  roleRef: {
    apiGroup: "rbac.authorization.k8s.io",
    kind: "ClusterRole",
    name: "sloop",
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "sloop",
      namespace: "sam-system",
    },
  ],
} else "SKIP"
