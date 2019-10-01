local configs = import "config.jsonnet";
local versions = import "stampy/versions.jsonnet";
local stampy_utils = import "stampy/stampy_utils.jsonnet";
local utils = import "util_functions.jsonnet";

if stampy_utils.apiserver.featureFlag then {
  apiVersion: "v1",
  kind: "Namespace",
  metadata: {
    name: "stampy-webhook",
    labels: {
          "stampy-injection": "disabled",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
  },
} else "SKIP"
