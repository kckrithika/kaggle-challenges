local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then {
   apiVersion: "apiextensions.k8s.io/v1beta1",
    kind: "CustomResourceDefinition",
    metadata: {
      name: "storedmanifestwatcherversions.samcrd.salesforce.com",
      annotations: {
        "manifestctl.sam.data.sfdc.net/swagger": "disable",
      },
      labels: {} + configs.ownerLabel.sam,
    },
    spec: {
      group: "samcrd.salesforce.com",
      version: "v1",
      scope: "Namespaced",
      names: {
        plural: "storedmanifestwatcherversions",
        singular: "storedmanifestwatcherversion",
        kind: "StoredManifestWatcherVersion",
        },
      },
} else "SKIP"
