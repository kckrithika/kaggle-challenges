// Ministry of EFun
// Contact: moe@salesforce.com
local configs = import "config.jsonnet";
local clusterNamespace = "legostore";
local appNamespace = "moe";

if configs.estate == "prd-sam" then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "moe-hdd-pool",
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
