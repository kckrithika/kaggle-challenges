local configs = import "config.jsonnet";

if configs.kingdom == "prd" then {
    apiVersion: "apiextensions.k8s.io/v1beta1",
    kind: "CustomResourceDefinition",
    metadata: {
        name: "samappstatuses.samcrd.salesforce.com",
    },
    spec: {
        group: "samcrd.salesforce.com",
        version: "v1",
        scope: "Namespaced",
        names: {
            plural: "samappstatuses",
            singular: "samappstatus",
            kind: "SamAppStatus",
        },
    },
} else "SKIP"
