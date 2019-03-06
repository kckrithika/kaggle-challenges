{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "istio-sidecar-injector-mesh-control-plane",
    labels: {
      app: "istio-sidecar-injector",
      chart: "sidecarInjectorWebhook-1.0.1",
      heritage: "Tiller",
      release: "RELEASE-NAME",
    },
  },
  rules: [
    {
      apiGroups: [
        "*",
      ],
      resources: [
        "configmaps",
      ],
      verbs: [
        "get",
        "list",
        "watch",
      ],
    },
    {
      apiGroups: [
        "admissionregistration.k8s.io",
      ],
      resources: [
        "mutatingwebhookconfigurations",
      ],
      verbs: [
        "get",
        "list",
        "watch",
        "patch",
      ],
    },
  ],
}
