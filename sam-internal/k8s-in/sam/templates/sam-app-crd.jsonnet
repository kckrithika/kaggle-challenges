local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

{
   apiVersion: "apiextensions.k8s.io/v1beta1",
    kind: "CustomResourceDefinition",
    metadata: {
      name: "samapps.samcrd.salesforce.com",
      annotations: {
        "manifestctl.sam.data.sfdc.net/swagger": "disable",
      },
      labels: {} + configs.ownerLabel.sam + configs.pcnEnableLabel,
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
}
