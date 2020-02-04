local makeds = (import "templates/sloop-ds-template.libsonnet").template;
local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local monitoredestates = (import "util_functions.jsonnet").get_sloop_estates(configs.estate);

if samfeatureflags.sloop then {
  apiVersion: "v1",
  kind: "List",
  metadata: {
      namespace: "sam-system",
  },
  items: [makeds(x) for x in monitoredestates],
} else "SKIP"
