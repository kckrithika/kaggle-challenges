{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRoleBinding",
  metadata: {
    name: "istio-sidecar-injector-admin-role-binding-mesh-control-plane",
    labels: {
      app: "istio-sidecar-injector",
      chart: "sidecarInjectorWebhook-1.0.1",
      heritage: "Tiller",
      release: "RELEASE-NAME",
    },
  },
  roleRef: {
    apiGroup: "rbac.authorization.k8s.io",
    kind: "ClusterRole",
    name: "istio-sidecar-injector-mesh-control-plane",
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "istio-sidecar-injector-service-account",
      namespace: "istio-system",
    },
  ],
}
