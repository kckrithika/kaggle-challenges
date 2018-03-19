local configs = import "config.jsonnet";
local clusterNamespace = "legostore";
local appNamespace = "sam-system";

if configs.estate == "prd-sam" then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "sdn-dashboard-hdd-pool",
        "namespace": appNamespace,
        "annotations": {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    "spec": {
        "clusterNamespace": clusterNamespace,
        "size": "2Ti",
        "storageTier": "hdd" ,
    }
} else "SKIP"
