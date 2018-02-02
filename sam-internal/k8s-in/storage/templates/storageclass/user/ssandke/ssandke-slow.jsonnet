local configs = import "config.jsonnet";
local appNamespace = "user-ssandke";
local clusterNamespace = "legostore";

if configs.estate == "prd-sam" then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "ssandke-slow",
        "namespace": appNamespace,
        "annotations": {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    "spec": {
        "clusterNamespace": clusterNamespace,
        "size": "5Gi",
        "storageTier": "hdd" ,
    }
} else "SKIP"
