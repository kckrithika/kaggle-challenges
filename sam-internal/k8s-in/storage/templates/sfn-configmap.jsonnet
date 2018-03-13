local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageutils = import "storageutils.jsonnet";

local selector = |||
  pods:
      matchExpressions:
        - {key: cloud, operator: In, values: [storage]}
  nodes:
      matchExpressions:
        - {key: pool, operator: In, values: [prd-sam_storage, prd-sam_cephdev]}
  persistentvolumes:
      matchExpressions:
        - {key: pool, operator: In, values: [prd-sam_storage, prd-sam_cephdev]}
  persistentvolumeclaims:
      matchExpressions:
        - {key: daemon, operator: In, values: [mon, osd]}
  statefulsets:
      matchExpressions:
        - {key: daemon, operator: In, values: [mon, osd]}
|||;


if configs.estate == "prd-sam_storage" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "sfn-config",
      namespace: "sam-system",
    },
    data: {
      "sfn-selectors.yaml": selector,
    },
} else "SKIP"

/*
    data: {
      "sfn-selector.yaml": std.toString(import "configs/sfn-selector-config.jsonnet"),
    },
*/



