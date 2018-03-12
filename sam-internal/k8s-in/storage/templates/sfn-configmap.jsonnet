local configs = import "config.jsonnet";
local selector = |||
  pods:
      matchExpressions:
        - {key: cloud, operator: In, values: [storage]}
  nodes:
      matchExpressions:
        - {key: pool, operator: In, values: [prd-sam_ceph]}
  persistentvolumes:
      matchExpressions:
        - {key: pool, operator: In, values: [prd-sam_ceph]}
  persistentvolumeclaims:
      matchExpressions:
        - {key: namespace, operator: In, values: [legostore]}
  statefulsets:
      matchExpressions:
        - {key: namespace, operator: In, values: [legostore]}
|||;


if configs.estate == "prd-sam_storage" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "sfn-config",
      namespace: "sam-system",
    },
    data: {
      "sfn-selector.yaml": selector,
    },
} else "SKIP"

/*
    data: {
      "sfn-selector.yaml": std.toString(import "configs/sfn-selector-config.jsonnet"),
    },
*/



