local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";
local clusterNamespace = "legostore";
local appNamespace = "flowsnake";

if utils.is_cephstorage_supported(configs.estate) then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "mysql-hdd-pool",
        "namespace": appNamespace,
        "annotations": {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    "spec": {
        "clusterNamespace": clusterNamespace,
        "size": "100Gi",
        "storageTier": "hdd" ,
    }
} else "SKIP"
