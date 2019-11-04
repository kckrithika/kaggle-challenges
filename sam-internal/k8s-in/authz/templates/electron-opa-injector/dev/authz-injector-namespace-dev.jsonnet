local configs = import "config.jsonnet";
local versions = import "authz/versions.jsonnet";
local electron_opa_utils = import "authz/electron_opa_utils.jsonnet";

if electron_opa_utils.is_electron_opa_injector_dev_cluster(configs.estate) then
{
  apiVersion: "v1",
  kind: "Namespace",
  metadata: {
    labels: {
      "electron-opa-injection": "disabled",
    },
    name: versions.newInjectorNamespace,
  },
} else "SKIP"
