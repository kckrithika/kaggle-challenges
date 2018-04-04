local configs = import "config.jsonnet";

// Defines the list of estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam_storage",
    "prd-sam",
    "prd-skipper",
    "phx-sam",
]);

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

if std.setMember(configs.estate, enabledEstates) then {
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
