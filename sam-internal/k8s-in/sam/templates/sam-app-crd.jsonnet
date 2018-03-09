local configs = import "config.jsonnet";

if configs.kingdom == "prd" then {
   apiVersion: "apiextensions.k8s.io/v1beta1",
    kind: "CustomResourceDefinition",
    metadata: {
      name: "samapps.samcrd.salesforce.com",
      annotations: {
        "manifestctl.sam.data.sfdc.net/swagger": "disable",
      },
    },
    spec: {
      group: "samcrd.salesforce.com",
      version: "v1",
      scope: "Namespaced",
      names: {
        plural: "samapps",
        singular: "samapp",
        kind: "SamApp",
        },
      },
} else "SKIP"
