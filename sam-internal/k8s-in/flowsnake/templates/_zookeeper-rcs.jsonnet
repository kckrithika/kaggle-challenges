local flowsnakeimage = import "flowsnake_images.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
{
    connection_string:: std.join(",", ["zookeeper-" + ri + ".zookeeper-set" + ":" + $.zk_port for ri in std.range(0, $.zk_replicas - 1)]),
    zk_port:: 2181,
    zk_replicas:: if flowsnakeconfig.is_minikube_small then 1 else 3,
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
                        image: flowsnakeimage.zookeeper,
                        imagePullPolicy: if flowsnakeconfig.is_minikube then "Never" else "Always",
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
}
