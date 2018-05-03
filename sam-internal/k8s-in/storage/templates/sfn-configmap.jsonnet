local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local storageutils = import "storageutils.jsonnet";
// Defines the list of estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam_storage",
    "prd-sam",
    "phx-sam",
    "xrd-sam",
]);

if std.setMember(configs.estate, enabledEstates) then {
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
