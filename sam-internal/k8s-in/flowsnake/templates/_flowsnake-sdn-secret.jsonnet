local configs = import "config.jsonnet";
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
