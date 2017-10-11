local configs = import "config.jsonnet";

if configs.kingdom == "prd" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "ops-adhoc",
      namespace: "sam-system",
    },
    # Always leave this point to ops-adhoc-nop when not in use.  To target one estate use an if statement here
    data: {
      "ops-adhoc.sh": std.toString(importstr "scripts/ops-adhoc-fixlogs.sh")
    } 
} else 
  "SKIP"
