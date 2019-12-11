# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 3) then
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
      failurePolicy: "Ignore",
      name: "sidecar-injector.istio.io",
      namespaceSelector: {
        matchLabels: {
          "istio-injection": "enabled",
        },
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