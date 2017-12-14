local configs = import "config.jsonnet";
local clusterNamespace = (if configs.estate == "prd-sam_storage"  then "ceph-test" else if configs.estate == "prd-sam" then "legostore" else "ceph");
local appNamespace = (if configs.estate == "prd-sam_storage"  then "gater-apps" else if configs.estate == "prd-sam" then "gater" else "");

if configs.estate == "prd-sam" then {
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
