local flowsnakeauthtopic = import "flowsnake_configmap.jsonnet";
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "samcontrol-deployer",
        namespace: "sam-system",
    },
    data: {
        "samcontroldeployer.json": std.toString(flowsnakeauthtopic.samcontroldeployer),
    },
}
