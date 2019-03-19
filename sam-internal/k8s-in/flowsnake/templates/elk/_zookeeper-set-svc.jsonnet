local zookeeper = import "_zookeeper-rcs.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_v1_enabled && !std.objectHas(flowsnake_images.feature_flags, "glok_retired") then
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "zookeeper-set",
        namespace: "flowsnake",
    },
    spec: {
        selector: {
            app: "glok-zk",
        },
        clusterIP: "None",
        ports: [
            {
                port: zookeeper.zk_port,
                name: "zk2181",
            },
            {
                port: 2888,
                name: "zk2888",
            },
            {
                port: 3888,
                name: "zk3888",
            },
        ],
    },
} else "SKIP"
