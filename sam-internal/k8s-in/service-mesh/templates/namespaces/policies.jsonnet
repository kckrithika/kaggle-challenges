local mesh_namespaces = [ "service-mesh", "gater", "mesh-control-plane"];

{
  "apiVersion": "v1",
  "items": [
    {
      "apiVersion": "authentication.istio.io/v1alpha1",
      "kind": "Policy",
      "metadata": {
        "annotations": {
          "manifestctl.sam.data.sfdc.net/swagger": "disable"
        },
        "clusterName": "",
        "generation": 1,
        "name": "istio-mtls-enable",
        "namespace": namespace
      },
      "spec": {
        "peer_is_optional": true,
        "peers": [
          {
            "mtls": {}
          }
        ]
      }
    }
    for namespace in mesh_namespaces
  ],
  "kind": "List"
}
