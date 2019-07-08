local sammysqlservice = (import "sam/templates/mysql-service.jsonnet");
local configs = import "config.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-samtwo" || configs.estate == "prd-data-flowsnake" then sammysqlservice {
      metadata+: {
        namespace: "flowsnake",
      },
    } else "SKIP"
