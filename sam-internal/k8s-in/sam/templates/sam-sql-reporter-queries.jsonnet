local configs = import "config.jsonnet";

# NOTE- This configMap is going to csc-sam not sam-system because sql-query-reporter is a SamApp right now
# because it needs K4A secrets.  Sam apps can read configMaps, but can not ship configMaps, so we are using
# autodeployer for this.  Once sam-internals supports K4A we can move it all here

if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "samsqlqueries",
      namespace: "csc-sam",
    },
    data: {
      "sam-sql-queries.json": std.toString(import "configs/sam-sql-queries.jsonnet"),
    },
} else "SKIP"
