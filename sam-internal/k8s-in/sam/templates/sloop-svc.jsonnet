local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local makesvc = (import "templates/sloop-svc-template.libsonnet").template;
local monitoredestates = (import "util_functions.jsonnet").get_sloop_estates(configs.estate);

if samfeatureflags.sloop then {
  apiVersion: "v1",
  kind: "List",
  metadata: {
      namespace: "sam-system",
  },
  items: [makesvc(x) for x in monitoredestates],
} else "SKIP"
