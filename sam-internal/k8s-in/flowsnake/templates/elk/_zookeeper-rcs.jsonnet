local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local elk = import "elastic_search_logstash_kibana.jsonnet";
if flowsnakeconfig.is_v1_enabled && !std.objectHas(flowsnake_images.feature_flags, "glok_retired") then
{
    connection_string:: std.join(",", ["zookeeper-" + ri + ".zookeeper-set" + ":" + $.zk_port for ri in std.range(0, $.zk_replicas - 1)]),
    zk_port:: 2181,
    zk_replicas:: elk.zk_replicas,
    apiVersion: "apps/v1beta1",
    kind: "StatefulSet",
    metadata: {
        labels: {
            name: "zookeeper",
        },
        name: "zookeeper",
        namespace: "flowsnake",
    },
    spec: {
        updateStrategy: {
            type: "RollingUpdate",
        },
        replicas: $.zk_replicas,
        serviceName: "zookeeper-set",
        template: {
            metadata: {
                labels: {
                    name: "zookeeper",
                    app: "glok-zk",
                },
            },
            spec: {
                containers: [
                    {
                        name: "glok-zk",
                        image: flowsnake_images.zookeeper,
                        imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
                        env: [
                            {
                                name: "REPLICAS",
                                value: std.toString($.zk_replicas),
                            },
                            {
                                name: "ZOOKEEPER_HEADLESS_SERVICE",
                                value: "zookeeper-set",
                            },
                            {
                                name: "ZOOKEEPER_AUTOPURGE_HOURS",
                                value: "24",
                            },
                        ],
                        ports: [
                            {
                                containerPort: $.zk_port,
                                name: "zk2181",
                            },
                            {
                                containerPort: 2888,
                                name: "zk2888",
                            },
                            {
                                containerPort: 3888,
                                name: "zk3888",
                            },
                        ],
                        readinessProbe: {
                            exec: {
                                command: [
                                    "sh",
                                    "-c",
                                    "[ $(exec 5<>/dev/tcp/localhost/" + $.zk_port + " && echo ruok >&5 && cat <&5) == imok ]",
                                ],
                            },
                        },
                        livenessProbe: {
                            exec: {
                                command: [
                                    "sh",
                                    "-c",
                                    "[ $(exec 5<>/dev/tcp/localhost/" + $.zk_port + " && echo ruok >&5 && cat <&5) == imok ]",
                                ],
                            },
                            initialDelaySeconds: 180,
                        },
                    },
                ],
            },
        },
    },
} else "SKIP"
