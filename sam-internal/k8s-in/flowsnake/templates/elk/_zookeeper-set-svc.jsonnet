local zookeeper = import "_zookeeper-rcs.jsonnet";
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
}
