local configs = import "config.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube then
"SKIP"
else
{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "sfdchosts",
      namespace: "flowsnake",
    },
    data: {
      "hosts.json": std.toString(import "flowsnake_hosts.jsonnet"),
    },
}
