local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.kingdom == "cdu" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "ops-adhoc",
      namespace: "sam-system",
    },
    # Always leave this point to ops-adhoc-nop when not in use.  To target one estate use an if statement here
    data: {} +
    if configs.kingdom == "cdu" then 
    {
      "ops-adhoc.sh": std.toString(importstr "scripts/ops-adhoc-fixkubeconfig.sh")
    } 
    else
    {
      # This will replace the script in inactive kingdoms with a nop, just incase autodeployer does not delete the DS
      "ops-adhoc.sh": std.toString(importstr "scripts/ops-adhoc-nop.sh")
    }
} else 
  "SKIP"
