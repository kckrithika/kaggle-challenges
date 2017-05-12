local configs = import "config.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-samtest" || configs.estate == "prd-sdc" then {
  "apiVersion": "v1",
  "kind": "Secret",
  "metadata": {
    "name": "sdn",
    "namespace": "sam-system"
  },
  "type": "Opaque",

  "data": {
    /* No secret value here. Only the source to fetch it from. Source is authN/authZ protected. */
    "sambgppassword": "@SecretService/sdn_" + configs.kingdom + "/SamBgpPassword"
  }
} else "SKIP"
