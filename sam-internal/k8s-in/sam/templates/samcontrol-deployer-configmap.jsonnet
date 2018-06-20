local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "samcontrol-deployer",
        namespace: "sam-system",
        labels: {} + if configs.estate == "prd-samdev" then {
                owner: "sam",
              } else {},
    },
    data: {
        "samcontroldeployer.json": std.toString(import "configs/samcontrol-deployer-config.jsonnet"),
    },
}
