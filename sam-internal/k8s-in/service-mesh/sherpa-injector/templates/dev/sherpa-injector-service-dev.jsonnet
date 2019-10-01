local configs = import "config.jsonnet";
local versions = import "service-mesh/sherpa-injector/versions.jsonnet";
local sherpa_utils = import "service-mesh/sherpa-injector/sherpa_utils.jsonnet";
local utils = import "util_functions.jsonnet";

if sherpa_utils.is_sherpa_injector_dev_cluster(configs.estate) then
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "sherpa-injector",
    namespace: versions.injectorNamespace,
    labels: {
      app: "sherpa-injector",
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
      app: "sherpa-injector",
    },
  },
} else "SKIP"
