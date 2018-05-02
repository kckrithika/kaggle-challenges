local configs = import "config.jsonnet";
local clusterNamespace = (if configs.estate == "prd-sam_storage" then "ceph-prd-sam-storage" else "legostore");
local appNamespace = "legostore";

if configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "lego-hdd-pool",
        "namespace": appNamespace,
        "annotations": {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    "spec": {
        "clusterNamespace": clusterNamespace,
        "size": "500Gi",
        "storageTier": "ssd" ,
    }
} else "SKIP"
