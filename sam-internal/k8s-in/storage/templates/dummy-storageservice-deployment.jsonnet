// This file exists solely for the purpose of providing an image promotion path for storage service images which are managed by operators.
// This provides a no-op Deployment (replica count is 0), but triggers an image promotion of the storage service TNRP images into production
// datacenters where this Deployment is applied.
local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" || configs.estate == "phx-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "dummy-storageservice-deployment",
            team: "storage-foundation",
            cloud: "storage",
        },
        name: "dummy-storageservice",
        namespace: "storage",
    },
    spec: {
        // This is intentionally set to 0. Do not change.
        replicas: 0,
        template: {
            metadata: {
                labels: {
                    name: "dummy-storageservice-deployment",
                    team: "storage-foundation",
                    cloud: "storage",
                },
            },
            spec: {
                containers: [
                    {
                        name: "cephdaemon",
                        image: storageimages.cephdaemon,
                    },
                    {
                        name: "sfstore-bookie",
                        image: storageimages.sfstorebookie,
                    },
                    {
                        name: "loginit",
                        image: storageimages.loginit,
                    },
                ],
            },
        },
    },
} else "SKIP"
