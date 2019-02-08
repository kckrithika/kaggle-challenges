# Enable mTLS as default between sidecars in service-mesh namespace
{
  apiVersion: "authentication.istio.io/v1alpha1",
  kind: "Policy",
  metadata: {
    name: "istio-mtls-enable",
    namespace: "service-mesh",
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
  },
  spec: {
    peers: [
      {
        mtls: {
        },
      },
    ],
  },
}
