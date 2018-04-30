local configs = import "config.jsonnet";
local clusterNamespace = "legostore";
local appNamespace = "mobile-monitoring";

if configs.estate == "prd-sam"  then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "mobile-monitoring-postgres-storage-hdd-pool",
        "namespace": appNamespace,
        "annotations": {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    "spec": {
        "clusterNamespace": clusterNamespace,
        "size": "10Gi",
        "storageTier": "hdd" ,
    }
} else "SKIP"
