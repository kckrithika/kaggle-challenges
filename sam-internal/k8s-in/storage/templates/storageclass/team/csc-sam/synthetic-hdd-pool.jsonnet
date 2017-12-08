local configs = import "config.jsonnet";
local clusterNamespace = (if configs.estate == "prd-sam_storage" then "ceph-test" else "legostore");
local appNamespace = "csc-sam";

if configs.estate == "prd-sam" then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "synthetic-hdd-pool",
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
