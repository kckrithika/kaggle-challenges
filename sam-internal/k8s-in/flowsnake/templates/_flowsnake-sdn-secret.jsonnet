local configs = import "config.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube then
"SKIP"
else
{
  apiVersion: "v1",
  kind: "Secret",
  metadata: {
    name: "sdn",
    namespace: "sam-system",
  },
  type: "Opaque",

  data: {
    /* No secret value here. Only the source to fetch it from. Source is authN/authZ protected. */
    flowsnakebgppassword: "@SecretService/sdn_" + configs.kingdom + "/flowsnakeBgpPassword",
  },
}
