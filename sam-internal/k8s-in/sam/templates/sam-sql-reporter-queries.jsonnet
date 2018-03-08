local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "samsqlqueries",
      namespace: "sam-system",
    },
    data: {
      "sam-sql-queries.json": std.toString(import "configs/sam-sql-queries.jsonnet"),
    },
} else "SKIP"
