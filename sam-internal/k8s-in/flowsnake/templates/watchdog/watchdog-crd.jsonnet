local estate = std.extVar("estate");

if estate == "prd-data-flowsnake_test" then ({
   apiVersion: "apiextensions.k8s.io/v1beta1",
    kind: "CustomResourceDefinition",
    metadata: {
      name: "watchdogs.samcrd.salesforce.com",
      annotations: {
        "manifestctl.sam.data.sfdc.net/swagger": "disable",
      },
      labels: {
        flowsnakeOwner: "dva-transform",
      }
    },
    spec: {
      group: "samcrd.salesforce.com",
      version: "v1",
      scope: "Namespaced",
      names: {
        plural: "watchdogs",
        singular: "watchdog",
        kind: "WatchDog",
        },
      },
}) else "SKIP"
