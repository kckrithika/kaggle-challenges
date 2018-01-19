local configs = import "config.jsonnet";
local clusterNamespace = (if configs.estate == "prd-sam_storage" then "ceph-prd-sam-storage" else "legostore");
local appNamespace = (if configs.estate == "prd-sam_storage" then "legostore" else "user-small");

if configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "small-hdd-pool",
        "namespace": appNamespace,
        "annotations": {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    "spec": {
        "clusterNamespace": clusterNamespace,
        "size": "500Gi",
        "storageTier": "hdd" ,
    }
} else "SKIP"
