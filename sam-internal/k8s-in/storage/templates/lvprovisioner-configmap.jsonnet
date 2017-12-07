local configs = import "config.jsonnet";
local node = |||
        - failure-domain.beta.kubernetes.io/zone
        - failure-domain.beta.kubernetes.io/region
        - kubernetes.io/hostname
        - node.sam.sfdc.net/pool
        - pool
        - node.sam.sfdc.net/rack
        - node.sam.sfdc.net/role
|||;

local storclass = |||
         ssd:
           hostDir: "/mnt/lvssd"
           mountDir: /local-ssd
         hdd:
           hostDir: "/mnt/lvhdd"
           mountDir: /local-hdd
|||;

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" || configs.estate == "phx-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "local-volume-sfdc-config",
      namespace: "storage-foundation",
    },
    data: {
      storageClassMap: storclass,
      nodeLabelsForPV: node,
    },
} else "SKIP"
