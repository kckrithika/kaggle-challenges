local configs = import "config.jsonnet";
local electron_opa_utils = import "authz/electron_opa_utils.jsonnet";

if electron_opa_utils.is_electron_opa_injector_prod_cluster(configs.estate) && electron_opa_utils.can_deploy(configs.kingdom) then
{
  apiVersion: "v1",
  kind: "Namespace",
  metadata: {
    labels: {
      "electron-opa-injection": "disabled",
    },
    name: "authz-injector",
  },
} else "SKIP"
