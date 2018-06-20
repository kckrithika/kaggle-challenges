local configs = import "config.jsonnet";

if configs.kingdom == "prd" then {
   apiVersion: "apiextensions.k8s.io/v1beta1",
    kind: "CustomResourceDefinition",
    metadata: {
      name: "dockerimages.samcrd.salesforce.com",
      annotations: {
        "manifestctl.sam.data.sfdc.net/swagger": "disable",
      },
      labels: {} + if configs.estate == "prd-samdev" then {
        owner: "sam",
      } else {},
    },
    spec: {
      group: "samcrd.salesforce.com",
      version: "v1",
      scope: "Cluster",
      names: {
        plural: "dockerimages",
        singular: "docker",
        kind: "DockerImage",
        },
      },
} else "SKIP"
