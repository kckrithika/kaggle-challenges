local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local storageutils = import "storageutils.jsonnet";

if configs.estate == "phx-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "sfn-config",
      namespace: "sam-system",
    },
    data: {
      "sfn-selectors.yaml": storageutils.make_sfn_selector_rule(storageconfigs.storageEstates),
    },
} else "SKIP"
