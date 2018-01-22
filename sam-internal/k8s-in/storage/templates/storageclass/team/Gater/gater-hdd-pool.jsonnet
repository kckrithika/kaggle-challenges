local configs = import "config.jsonnet";
local clusterNamespace = (if configs.estate == "prd-sam_storage" then "ceph-test" else "legostore");
local appNamespace = (if configs.estate == "prd-sam_storage" then "gater-apps" else "gater");

if configs.estate == "prd-sam" || configs.estate == "phx-sam" then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "gater-hdd-pool",
        "namespace": appNamespace,
        "annotations": {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    "spec": {
        "clusterNamespace": clusterNamespace,
        "size": "750Gi",
        "storageTier": "hdd" ,
    }
} else "SKIP"
