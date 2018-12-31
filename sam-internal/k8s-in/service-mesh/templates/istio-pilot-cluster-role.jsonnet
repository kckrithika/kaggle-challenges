local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";

{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "istio-pilot-mesh-control-plane",
    labels: istioUtils.istioLabels,
  },
  rules: [
    {
      apiGroups: [
        "config.istio.io",
      ],
      resources: [
        "*",
      ],
      verbs: [
        "*",
      ],
    },
    {
      apiGroups: [
        "rbac.istio.io",
      ],
      resources: [
        "*",
      ],
      verbs: [
        "get",
        "watch",
        "list",
      ],
    },
    {
      apiGroups: [
        "networking.istio.io",
      ],
      resources: [
        "*",
      ],
      verbs: [
        "*",
      ],
    },
    {
      apiGroups: [
        "authentication.istio.io",
      ],
      resources: [
        "*",
      ],
      verbs: [
        "*",
      ],
    },
    {
      apiGroups: [
        "apiextensions.k8s.io",
      ],
      resources: [
        "customresourcedefinitions",
      ],
      verbs: [
        "*",
      ],
    },
    {
      apiGroups: [
        "extensions",
      ],
      resources: [
        "thirdpartyresources",
        "thirdpartyresources.extensions",
        "ingresses",
        "ingresses/status",
      ],
      verbs: [
        "*",
      ],
    },
    {
      apiGroups: [
        "",
      ],
      resources: [
        "configmaps",
      ],
      verbs: [
        "create",
        "get",
        "list",
        "watch",
        "update",
      ],
    },
    {
      apiGroups: [
        "",
      ],
      resources: [
        "endpoints",
        "pods",
        "services",
      ],
      verbs: [
        "get",
        "list",
        "watch",
      ],
    },
    {
      apiGroups: [
        "",
      ],
      resources: [
        "namespaces",
        "nodes",
        "secrets",
      ],
      verbs: [
        "get",
        "list",
        "watch",
      ],
    },
  ],
}
