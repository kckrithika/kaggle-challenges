local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "prd-sam_storage" then {
    apiVersion: "storage.salesforce.com/v1beta1",
    kind: "SfstoreCluster",
    metadata: {
      name: configs.estate,
      namespace: "sfstore",
    },
    spec: {
      version: "1.10",
      faultDomainBoundary: "rack",
      aggregateStorage: "300Gi",
    },
} else "SKIP"
