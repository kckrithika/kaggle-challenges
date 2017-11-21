local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageconfigs = import "storageconfigs.jsonnet";

if configs.estate == "prd-sam_storage" then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "gater-hdd-pool",
        "namespace": "gater-apps",
        "annotations": {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    "spec": {
        "size": "500Gi",
        "storageTier": "hdd"
    }
} else "SKIP"
