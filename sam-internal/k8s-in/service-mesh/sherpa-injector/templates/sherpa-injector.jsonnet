local configs = import "config.jsonnet";
local versions = import "service-mesh/sherpa-injector/versions.jsonnet";
local utils = import "util_functions.jsonnet";

{
  apiVersion: "v1",
  kind: "Namespace",
  metadata: {
    name: "sherpa-injector-test",
    labels: {
          "sherpa-injector.service-mesh/inject": "disabled",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
  },
}
