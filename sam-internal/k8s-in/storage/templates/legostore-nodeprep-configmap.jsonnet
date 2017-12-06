local configs = import "config.jsonnet";
local discoveryCfg = |||
    - hostDiscoveryDir: /mnt/lvhdd
      mountDevices:
        - data-0
        - data-1
        - data-2
        - data-3
        - data-4
        - data-5
        - data-6
    - hostDiscoveryDir: /mnt/lvssd
      mountDevices:
        -  fastdata-1
        -  fastdata-2
        -  fastdata-3
|||;

if configs.estate == "prd-sam_storage" then {
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
      name: "legostore-nodeprep-config",
      namespace: "storage-foundation",
    },
    data: {
      discoveryConfig: discoveryCfg,
    },
} else "SKIP"
