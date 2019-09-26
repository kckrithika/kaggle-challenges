local configs = import "config.jsonnet";
local versions = import "stampy/versions.jsonnet";
local stampy_utils = import "stampy/stampy_utils.jsonnet";
local utils = import "util_functions.jsonnet";

if stampy_utils.is_stampy_webhook_dev_cluster(configs.estate) then
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "stampy-webhook",
    namespace: versions.injectorNamespace,
    labels: {
      app: "stampy-webhook",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
  },
  spec: {
    ports: [
      {
        name: "h1-tls-in-port",
        port: if utils.is_pcn(configs.kingdom) then 443 else 17772,
        targetPort: 17772,
      },
    ],
    selector: {
      app: "stampy-webhook",
    },
  },
} else "SKIP"
