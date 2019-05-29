# istio-inject: enabled enables both the webhooks - istio-sidecar-injector & istio-routing-webhook
local mesh_namespaces = ["app", "service-mesh", "gater", "ccait", "core-on-sam-sp2", "core-on-sam"];
{
  apiVersion: "v1",
  items: [
    {
      apiVersion: "v1",
      kind: "Namespace",
      metadata: {
        labels: {
          "istio-injection": "enabled",
        },
        name: namespace,
      },
    }
    for namespace in mesh_namespaces
  ],
  kind: "List",
}
