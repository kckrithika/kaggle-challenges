local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "temp-secret-samcontrol-deployer",
        namespace: "sam-system",
    },
    data: {
        "tempsecretsamcontroldeployer.json": std.toString(import "configs/temp-secret-samcontrol-deployer-config.jsonnet"),
    },
}
