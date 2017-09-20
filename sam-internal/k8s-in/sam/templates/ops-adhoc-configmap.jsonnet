local configs = import "config.jsonnet";

# Turned off by default.  Enable when needed
if "0" == "1" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "ops-adhoc",
      namespace: "sam-system",
    },
    # Always leave this point to ops-adhoc-nop when not in use.  To target one estate use an if statement here
    data: {
      "ops-adhoc.sh": std.toString(importstr "scripts/ops-adhoc-fixkubeconfig.sh")
    } 
} else 
  "SKIP"
