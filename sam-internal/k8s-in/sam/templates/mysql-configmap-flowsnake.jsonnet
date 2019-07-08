local sammysqlconfigmap = (import "sam/templates/mysql-configmap.jsonnet");
local configs = import "config.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-samtwo" || configs.estate == "prd-data-flowsnake" then sammysqlconfigmap {
      metadata+: {
        namespace: "flowsnake",
      },
    } else "SKIP"
