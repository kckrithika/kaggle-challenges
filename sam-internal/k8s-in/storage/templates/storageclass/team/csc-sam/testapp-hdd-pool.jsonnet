local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";
local clusterNamespace = (if configs.estate == "prd-sam_storage" then "ceph-test" else "legostore");
local appNamespace = "csc-sam";

if utils.is_cephstorage_supported(configs.estate) then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "testapp-hdd-pool",
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
