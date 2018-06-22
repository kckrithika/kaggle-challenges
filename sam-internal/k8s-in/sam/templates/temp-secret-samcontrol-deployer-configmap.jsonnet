local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "temp-secret-samcontrol-deployer",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "tempsecretsamcontroldeployer.json": std.toString(import "configs/temp-secret-samcontrol-deployer-config.jsonnet"),
    },
}
