local mesh_namespaces = [ "service-mesh", "gater", "ccait", "core-on-sam-sp2", "core-on-sam"];
{
  "apiVersion": "v1",
  "items": [
    {
      "apiVersion": "v1",
      "kind": "Namespace",
      "metadata": {
        "labels": {
          "istio-injection": "enabled"
        },
        "name": namespace
      }
    },
    for namespace in mesh_namespaces
  ],
  "kind": "List"
}
