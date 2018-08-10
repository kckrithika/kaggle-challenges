local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local storageutils = import "storageutils.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
// Defines the list of estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam_storage",
    "prd-sam",
]);

if std.setMember(configs.estate, enabledEstates) then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "sfn-config",
      namespace: "sam-system",
    },
    data: {
      "sfn-selectors.yaml": storageutils.make_sfn_selector_rule(storageconfigs.storageEstates, configs.estate),
    },
} else "SKIP"
