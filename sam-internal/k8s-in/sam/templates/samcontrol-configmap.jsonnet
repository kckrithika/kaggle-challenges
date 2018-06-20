local configs = import "config.jsonnet";

{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "samcontrol",
        namespace: "sam-system",
        labels: {} + if configs.estate == "prd-samdev" then {
                owner: "sam",
              } else {},
    },
    data: {
        "samcontrol.json": std.toString(import "configs/samcontrol-config.jsonnet"),
    },
}
