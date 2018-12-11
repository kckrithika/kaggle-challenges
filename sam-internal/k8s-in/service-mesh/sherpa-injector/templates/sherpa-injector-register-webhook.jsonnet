{
  apiVersion: "admissionregistration.k8s.io/v1beta1",
  kind: "MutatingWebhookConfiguration",
  metadata: {
    name: "sherpa-injector-cfg",
    labels: {
      app: "sherpa-injector",
    },
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
  },
  webhooks: [
    {
      name: "sherpa-injector.service-mesh.svc",
      clientConfig: {
        service: {
          name: "sherpa-injector-svc",
          namespace: "service-mesh",
          path: "/mutate",
        },
        caBundle: "CA-BUNDLE-HERE",
      },
      rules: [
        {
          apiGroups: [
            "apps",
            "",
          ],
          apiVersions: [
            "v1",
          ],
          operations: [
            "CREATE",
          ],
          resources: [
            "pods",
          ],
        },
      ],
      failurePolicy: "Ignore",  //TODO: Set to "Fail", when the code/configs are stable
      namespaceSelector: {
        matchExpressions: [
          {
            key: "sherpa-injector.service-mesh/inject",
            operator: "NotIn",
            values: [
              "disabled",
            ],
          },
        ],
      },
    },
  ],
}
