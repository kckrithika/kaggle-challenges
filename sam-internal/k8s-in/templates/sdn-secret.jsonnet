{
  local configs = import "config.jsonnet",

  "apiVersion": "v1",
  "kind": "Secret",
  "metadata": {
    "name": "sdn",
    "namespace": "sam-system"
  },
  "type": "Opaque",

  "data": {
    "sambgppassword": "@SecretService/sdn_" + configs.kingdom + "/SamBgpPassword"
  }
}