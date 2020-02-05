local configs = import "config.jsonnet";
local versions = import "authz/versions.jsonnet";
local electron_opa_utils = import "authz/electron_opa_utils.jsonnet";

if configs.estate == "prd-sam" then
{
  apiVersion: "v1",
  kind: "Namespace",
  metadata: {
    labels: {
      "electron-opa-injection": "disabled",
    },
    name: versions.injectorNamespace,
  },
} else "SKIP"
