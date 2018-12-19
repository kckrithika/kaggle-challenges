# Enable mTLS as default between sidecars in mesh-control-plane namespace
{
  apiVersion: "authentication.istio.io/v1alpha1",
  kind: "Policy",
  metadata: {
    name: "mTLS-enable",
    namespace: "mesh-control-plane",
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
