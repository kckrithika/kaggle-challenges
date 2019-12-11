# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "admissionregistration.k8s.io/v1beta1",
  kind: "MutatingWebhookConfiguration",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "sidecarInjectorWebhook",
      release: "istio",
    },
    name: "istio-sidecar-injector",
  },
  webhooks: [
    {
      clientConfig: {
        caBundle: "",
        service: {
          name: "istio-sidecar-injector",
          namespace: "mesh-control-plane",
          path: "/inject",
        },
      },
      failurePolicy: "Fail",
      name: "sidecar-injector.istio.io",
      namespaceSelector: {
        matchExpressions: [
          {
            key: "name",
            operator: "NotIn",
            values: [
              "mesh-control-plane",
            ],
          },
          {
            key: "istio-injection",
            operator: "NotIn",
            values: [
              "disabled",
            ],
          },
        ],
      },
      rules: [
        {
          apiGroups: [
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
    },
  ],
}
else "SKIP"
