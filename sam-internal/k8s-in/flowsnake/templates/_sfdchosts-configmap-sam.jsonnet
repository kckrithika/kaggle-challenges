local configs = import "config.jsonnet";
# This is identical to _sfdchosts-configmap.jsonnet, but in the sam-system namespace. Currently we have two because component auto-deployer expects this data in this namespace.
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube then
"SKIP"
else
{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "sfdchosts",
      namespace: "sam-system",
    },
    data: {
      "hosts.json": std.toString(import "flowsnake_hosts.jsonnet"),
    },
}
