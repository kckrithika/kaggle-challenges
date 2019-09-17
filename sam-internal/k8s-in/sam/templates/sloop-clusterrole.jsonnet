local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

# Modeled after https://github.com/helm/charts/blob/master/stable/kube-state-metrics/templates/clusterrole.yaml

if samfeatureflags.sloop then {
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "sloop",
  },
  rules: [
    {
      apiGroups: [""],
      resources: [
        "configmaps",
        "endpoints",
        "limitranges",
        "namespaces",
        "nodes",
        "persistentvolumeclaims",
        "persistentvolumes",
        "pods",
        "replicationcontrollers",
        "resourcequotas",
        "services",
      ],
      verbs: ["list", "watch"],
    },
    {
      apiGroups: ["batch"],
      resources: [
        "cronjobs",
        "jobs",
      ],
      verbs: ["list", "watch"],
    },
    {
      apiGroups: ["extensions", "apps"],
      resources: [
        "daemonsets",
        "deployments",
        "replicasets",
        "",
      ],
      verbs: ["list", "watch"],
    },
    {
      apiGroups: ["autoscaling"],
      resources: [
        "horizontalpodautoscalers",
      ],
      verbs: ["list", "watch"],
    },
    {
      apiGroups: ["extensions", "networking.k8s.io"],
      resources: [
        "ingress",
      ],
      verbs: ["list", "watch"],
    },
    {
      apiGroups: ["policy"],
      resources: [
        "poddisruptionbudgets",
      ],
      verbs: ["list", "watch"],
    },
    {
      apiGroups: ["storage.k8s.io"],
      resources: [
        "storageclasses",
      ],
      verbs: ["list", "watch"],
    },
    {
      apiGroups: ["autoscaling.k8s.io"],
      resources: [
        "verticalpodautoscalers",
      ],
      verbs: ["list", "watch"],
    },
  ],
} else "SKIP"
