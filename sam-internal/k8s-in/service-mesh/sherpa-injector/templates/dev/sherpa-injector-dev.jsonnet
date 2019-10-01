local configs = import "config.jsonnet";
local versions = import "service-mesh/sherpa-injector/versions.jsonnet";
local sherpa_utils = import "service-mesh/sherpa-injector/sherpa_utils.jsonnet";
local utils = import "util_functions.jsonnet";

if sherpa_utils.is_sherpa_injector_dev_cluster(configs.estate) then
{
  apiVersion: "v1",
  kind: "Namespace",
  metadata: {
    name: "sherpa-injector-dev",
    labels: {
          "sherpa-injector-dev.service-mesh/inject": "disabled",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
  },
} else "SKIP"

