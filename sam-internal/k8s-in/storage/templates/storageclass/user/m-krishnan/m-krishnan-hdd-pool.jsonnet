local configs = import "config.jsonnet";
local appNamespace = (if configs.estate == "prd-sam" then "user-m-krishnan" else "");

if configs.estate == "prd-sam" then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "m-krishnan-hdd-pool",
        "namespace": appNamespace,
        "annotations": {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    "spec": {
        "clusterNamespace": "legostore",
        "size": "10Gi",
        "storageTier": "hdd" ,
    }
} else "SKIP"
