local configs = import "config.jsonnet";
local discoveryCfg = |||
    - hostDiscoveryDir: /mnt/lvssd
      mountDevices:
        -  fastdata-0
        -  fastdata-1
        -  fastdata-2
        -  fastdata-3
|||;

if configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" then {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      name: "sfstore-nodeprep-config",
      namespace: "storage-foundation",
    },
    data: {
      discoveryConfig: discoveryCfg,
    },
} else "SKIP"
