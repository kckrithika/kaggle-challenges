local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "samcontrol-deployer",
      namespace: "sam-system",
    },
    data: {
      "samcontroldeployer.json": std.toString(import "../configs-sam/samcontrol-deployer-config.jsonnet")
    }
}
