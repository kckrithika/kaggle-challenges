local configs = import "config.jsonnet";
{
  kind: "Namespace",
  apiVersion: "v1",
  metadata: {
    name: "service-discovery",
  },
}
