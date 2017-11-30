local configs = import "config.jsonnet";
local node = |||
        - failure-domain.beta.kubernetes.io/zone
        - failure-domain.beta.kubernetes.io/region
        - kubernetes.io/hostname
|||;

local storclass = |||
         ssd:
           hostDir: "/mnt/lvssds"
           mountDir: /local-ssds
         hdd:
           hostDir: "/mnt/lvhdds"
           mountDir: /local-hdds
|||;

if configs.estate == "prd-sam_storage" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "local-volume-sfdc-config",
      namespace: "sam-system",
    },
    data: {
      storageClassMap: storclass,
      nodeLabelsForPV: node,
    },
} else "SKIP"
