local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";
local clusterNamespace = "legostore";
local appNamespace = "distributed-tracing";

if configs.estate == "prd-sam"  then {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "zipkin-es-persistent-storage-hdd-pool",
        "namespace": appNamespace,
        "annotations": {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    "spec": {
        "clusterNamespace": clusterNamespace,
        "size": "10Ti",
        "storageTier": "hdd" ,
    }
} else "SKIP"