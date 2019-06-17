local configs = import "config.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samtwo" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "samsqlqueries",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam,
    },
    data: {
        "sam-sql-queries.json": std.toString(import "configs/sam-sql-queries.jsonnet"),
    },
} else "SKIP"
