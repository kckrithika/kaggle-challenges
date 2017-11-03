local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "temp-samcontrol-deployer",
      namespace: "sam-system",
    },
    data: {
      "tempsamcontroldeployer.json": std.toString(import "configs/temp-samcontrol-deployer-config.jsonnet"),
    },
} else "SKIP"
