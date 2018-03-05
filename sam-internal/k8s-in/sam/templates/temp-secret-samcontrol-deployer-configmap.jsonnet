local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.kingdom == "frf" || configs.kingdom == "iad" || configs.kingdom == "ord" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "temp-secret-samcontrol-deployer",
      namespace: "sam-system",
    },
    data: {
      "tempsecretsamcontroldeployer.json": std.toString(import "configs/temp-secret-samcontrol-deployer-config.jsonnet"),
    },
} else "SKIP"
