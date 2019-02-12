{
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "istio-sidecar-injector-service-account",
    namespace: "mesh-control-plane",
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "istio-sidecar-injector",
      chart: "sidecarInjectorWebhook-1.0.1",
      heritage: "Tiller",
      release: "RELEASE-NAME",
    },
  },
}
