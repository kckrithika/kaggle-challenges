# This is identical to _sfdchosts-configmap.jsonnet, but in the sam-system namespace. Currently we have two because component auto-deployer expects this data in this namespace.
local auto_deployer = import "auto_deployer.jsonnet";
if !auto_deployer.auto_deployer_enabled then
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
