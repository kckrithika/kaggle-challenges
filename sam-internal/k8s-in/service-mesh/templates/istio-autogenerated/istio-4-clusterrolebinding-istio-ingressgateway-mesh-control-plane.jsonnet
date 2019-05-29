# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "rbac.authorization.k8s.io/v1",
  kind: "ClusterRoleBinding",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "ingressgateway",
      release: "istio",
    },
    name: "istio-ingressgateway-core-on-sam-sp2",
  },
  roleRef: {
    apiGroup: "rbac.authorization.k8s.io",
    kind: "ClusterRole",
    name: "istio-ingressgateway-core-on-sam-sp2",
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "istio-ingressgateway-service-account",
      namespace: "core-on-sam-sp2",
    },
  ],
}
