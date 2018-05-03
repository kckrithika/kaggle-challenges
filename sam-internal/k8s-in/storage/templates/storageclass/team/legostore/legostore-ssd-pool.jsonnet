local configs = import "config.jsonnet";
local clusterNamespace = "legostore"; 
local appNamespace = "legostore";

if configs.estate == "phx-sam" then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "legostore-ssd-pool",
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
