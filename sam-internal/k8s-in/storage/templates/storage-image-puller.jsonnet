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
local imagefunctions = (import "image_functions.libsonnet") + { templateFilename:: std.thisFile };
local storageconfigs = import "storageconfig.jsonnet";
local storageutils = import "storageutils.jsonnet";
local affinitizeToStoragePool = configs.estate != "prd-skipper";

// Defines the set of control estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam_storage",
    "prd-sam",
    "prd-skipper",
    "phx-sam",
]);

// Local functions.
local internal = {
    puller_node_affinity(estate):: (
        if affinitizeToStoragePool then {
            nodeAffinity: {
                requiredDuringSchedulingIgnoredDuringExecution: {
                    nodeSelectorTerms: [{
                        matchExpressions: [{
                            key: "pool",
                            operator: "In",
                            values: [estate],
                        }],
                    }],
                },
            },
        } else {}
    ),

    init_container(index, image):: {
        name: "image-puller" + (if index > 0 then "-" + index else ""),
        image: image,
        command: [
            "/bin/bash",
            "-c",
            "echo successfully pulled image " + image,
        ],
    },

    init_containers(images):: [
        internal.init_container(index, images[index])
        for index in std.range(0, std.length(images) - 1)
    ],
};

local storageImageTypes = [
    # SFStore cluster images.
    {
        estate: minionEstate,
        type: "sfstore",
        images: [
            storageimages.sfstorebookie,
        ],
        minionEstates: storageconfigs.sfstoreEstates[configs.estate],
    }
    for minionEstate in storageconfigs.sfstoreEstates[configs.estate]
] + [
    # Ceph cluster images.
    {
        local cephdaemon_tag = storageutils.do_cephdaemon_tag_override(storageimages.overrides, minionEstate, storageimages.cephdaemon_tag),
        estate: minionEstate,
        type: "ceph",
        images: [
            imagefunctions.do_override_based_on_tag(storageimages.overrides, "storagecloud", "ceph-daemon", cephdaemon_tag),
        ],
        minionEstates: storageconfigs.cephEstates[configs.estate],
    }
    for minionEstate in storageconfigs.cephEstates[configs.estate]
];

if std.setMember(configs.estate, enabledEstates) then {
    apiVersion: "v1",
    kind: "List",
    items: [
    {
        // For control estates that have multiple minion estates, include the escaped minion
        // estate name in the daemonset name.
        local estateSpecificNamePortion = if std.length(storageImageType.minionEstates) > 1
            then "-" + storageutils.string_replace(storageImageType.estate, "_", "-")
            else "",
        local name = storageImageType.type + estateSpecificNamePortion + "-image-puller",
        local pauseimage = "gcr.io/google_containers/pause-amd64:3.0",

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
                    affinity: internal.puller_node_affinity(storageImageType.estate),
                    initContainers: internal.init_containers(storageImageType.images),
                    containers: [
                        {
                            name: "pause",
                            image: pauseimage,
                        },
                    ],
                },
            },
        },
    }
    for storageImageType in storageImageTypes
    ],
} else "SKIP"
