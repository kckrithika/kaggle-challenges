# Sidecar that applies to namespace `app` which is expected to be Core's ServiceEntry's namespace.
{
  apiVersion: "networking.istio.io/v1alpha3",
  kind: "Sidecar",
  metadata: {
    name: "istio-core-sidecar",
    namespace: "app",
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
  },
  spec: {
    egress: [
      {
        bind: "127.1.2.3",
        captureMode: "NONE",
        # Whitelist of Egress Services
        hosts: [
          "gater/gater.gater.svc.cluster.local",
          "ccait/geoip.ccait.svc.cluster.local",
        ],
      },
    ],
  },
}
