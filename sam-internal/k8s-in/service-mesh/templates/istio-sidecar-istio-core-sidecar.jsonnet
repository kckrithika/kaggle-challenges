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
//    ingress: [
//      {
//        port: {
//          number: 7443,  # Bind IP will be the host's actual IPV4 address.
//          protocol: "GRPC",
//          name: "grpc-core",
//        },
//        captureMode: "NONE",
//        defaultEndpoint: "127.0.0.1:7021",  # TODO: Change to 7020 after GRPC server listener change to 127.0.0.1:7020 (instead of 0.0.0.0:7020). 7021 for k8s->Core test.
//      },
//    ],
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
