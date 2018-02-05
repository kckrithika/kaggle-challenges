local configs = import "config.jsonnet";
local clusterNamespace = "legostore";
local appNamespace = "test-release";

if configs.estate == "prd-sam" then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "test-release-gocd-hdd-pool",
        "namespace": appNamespace,
        "annotations": {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    "spec": {
        "clusterNamespace": clusterNamespace,
        "size": "300Gi",
        "storageTier": "hdd" ,
    }
} else "SKIP"
