local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "watchdogsamsqlqueries",
        namespace: "sam-system",
        labels: {} + if configs.estate == "prd-samdev" then {
                owner: "sam",
              } else {},
    },
    data: {
        "watchdog-samsql-queries.jsonnet": std.toString(import "configs/watchdog-samsql-queries.jsonnet"),
        "watchdog-samsql-profiles.jsonnet": std.toString(import "configs/watchdog-samsql-profiles.jsonnet"),
    },
} else "SKIP"
