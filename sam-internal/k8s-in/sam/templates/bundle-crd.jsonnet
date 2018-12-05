local configs = import "config.jsonnet";

if configs.kingdom == "prd" || configs.kingdom == "vpod" || configs.kingdom == "frf" then {
   apiVersion: "apiextensions.k8s.io/v1beta1",
    kind: "CustomResourceDefinition",
    metadata: {
      name: "bundles.samcrd.salesforce.com",
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
        plural: "bundles",
        singular: "bundle",
        kind: "Bundle",
        },
      },
} else "SKIP"
