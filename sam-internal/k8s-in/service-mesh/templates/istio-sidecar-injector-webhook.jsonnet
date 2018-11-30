{
  apiVersion: "admissionregistration.k8s.io/v1beta1",
  kind: "MutatingWebhookConfiguration",
  metadata: {
    name: "istio-sidecar-injector",
    labels: {
      app: "istio-sidecar-injector",
      chart: "sidecarInjectorWebhook-1.0.1",
      release: "RELEASE-NAME",
      heritage: "Tiller",
    },
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
  },
  webhooks: [
    {
      name: "sidecar-injector.istio.io",
      clientConfig: {
        service: {
          name: "istio-sidecar-injector",
          namespace: "service-mesh",
          path: "/inject",
        },
        caBundle: "",
      },
      rules: [
        {
          operations: [
            "CREATE",
          ],
          apiGroups: [
            "",
          ],
          apiVersions: [
            "v1",
          ],
          resources: [
            "pods",
          ],
        },
      ],
      failurePolicy: "Ignore",
      namespaceSelector: {
        matchLabels: {
          "istio-injection": "enabled",
        },
      },
    },
  ],
}
