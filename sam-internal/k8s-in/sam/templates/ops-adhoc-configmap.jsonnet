local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "ops-adhoc",
      namespace: "sam-system",
    },
    # Always leave this point to ops-adhoc-nop when not in use.  To target one estate use an if statement here
    data: {} +
    if configs.estate == "prd-samtest" then 
    {
      "ops-adhoc": std.toString(importstr "scripts/ops-adhoc-fixkubeconfig.sh")
    } 
    else
    {
      "ops-adhoc": std.toString(importstr "scripts/ops-adhoc-nop.sh")
    }
} else 
  "SKIP"
