local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" || configs.estate == "phx-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "dummy-ceph-daemon",
        },
        name: "dummy-ceph-daemon",
        namespace: "storage",
    },
    spec: {
        replicas: 0,
        template: {
            spec: {
                containers: [
                    {
                        name: "cephdaemon",
                        image: storageimages.cephdaemon,
                    },
                ],
            },
        },
    },
} else "SKIP"
