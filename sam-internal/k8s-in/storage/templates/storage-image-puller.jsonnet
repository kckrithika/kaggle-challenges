// This "service" exists for the purpose of improving deployment & upgrade times for storage clusters.
// The basic idea is to schedule a pod with an init container referencing the desired image to all
// nodes in the storage cluster estate(s). This will cause the desired image to be pulled to all nodes
// concurrently. Any ongoing upgrade/deployment will then be able to immediately use the pre-pulled image
// on the node (except for the first one or two nodes hit by the deployment, which will have to wait for
// the image to be pulled).
//
// Because image pulls can take several minutes, this should vastly reduce the time needed to deploy/upgrade
// clusters.

local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" then {
    apiVersion: "v1",
    kind: "List",
    items: [
    {
        local name = storageImageType.name + "-image-puller",
        apiVersion: "extensions/v1beta1",
        kind: "DaemonSet",
        metadata: {
            labels: {
                name: name,
                team: "storage-foundation",
                cloud: "storage",
            },
            name: name,
            namespace: "storage-foundation",
        },
        spec: {
            template: {
                metadata: {
                    labels: {
                        name: name,
                        team: "storage-foundation",
                        cloud: "storage",
                    },
                },
                spec: {
                    affinity: {
                        nodeAffinity: {
                            requiredDuringSchedulingIgnoredDuringExecution: {
                                nodeSelectorTerms: [
                                {
                                    matchExpressions: [
                                    {
                                        key: "pool",
                                        operator: "In",
                                        values: storageImageType.estates,
                                    },
                                    ],
                                },
                                ],
                            },
                        },
                    },
                    initContainers: [
                        {
                            name: "image-puller",
                            image: storageImageType.image,
                            command: [
                                "/bin/bash",
                                "-c",
                                "echo successfully pulled image " + storageImageType.image,
                            ],
                        },
                    ],
                    containers: [
                        {
                            name: "pause",
                            image: "gcr.io/google_containers/pause-amd64:3.0",
                        },
                    ],
                },
            },
        },
    }
    for storageImageType in [
        {
            name: "sfstore",
            image: storageimages.sfstorebookie,
            estates: storageconfigs.sfstoreEstates[configs.estate],
        },
        {
            name: "ceph",
            image: storageimages.cephdaemon,
            estates: storageconfigs.cephEstates[configs.estate],
        },
    ]
    ],
} else "SKIP"
