local configs = import "config.jsonnet";
local versions = import "authz/versions.jsonnet";
local electron_opa_utils = import "authz/electron_opa_utils.jsonnet";
local utils = import "util_functions.jsonnet";

if electron_opa_utils.is_electron_opa_injector_test_cluster(configs.estate) then
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "electron-opa-injector",
    namespace: versions.injectorNamespace,
    labels: {
      app: "electron-opa-injector",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
  },
  spec: {
    ports: [
      {
        name: "h1-tls-in-port",
        port: if utils.is_pcn(configs.kingdom) then 443 else 17442,
        targetPort: 17442,
      },
    ],
    selector: {
      app: "electron-opa-injector",
    },
  },
} else "SKIP"
