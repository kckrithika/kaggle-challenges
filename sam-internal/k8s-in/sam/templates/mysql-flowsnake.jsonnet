local samsqlconfig = (import "../../sam/templates/mysql.jsonnet");
local configs = import "config.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-samtwo" || configs.estate == "prd-data-flowsnake" then samsqlconfig {
      metadata+: {
        namespace: "flowsnake",
      },
    }
 else "SKIP"
