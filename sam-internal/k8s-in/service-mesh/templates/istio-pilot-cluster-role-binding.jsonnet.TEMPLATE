local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";

{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRoleBinding",
  metadata: {
    name: "istio-pilot-service-mesh",
    labels: istioUtils.istioLabels,
  },
  roleRef: {
    apiGroup: "rbac.authorization.k8s.io",
    kind: "ClusterRole",
    name: "istio-pilot-service-mesh",
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "istio-pilot-service-account",
      namespace: "service-mesh",
    },
  ],
}
