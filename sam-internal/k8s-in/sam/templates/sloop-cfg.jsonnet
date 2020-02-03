local makeds = (import "templates/sloopds2.libsonnet").templ;
local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local monitoredestates = (import "util_functions.jsonnet").get_estate_port_mapping(configs.kingdom);

{
  apiVersion: "v1",
  kind: "List",
  metadata: {
      namespace: "sam-system",
  },
  items: [makeds(x.estate, x.targetport) for x in monitoredestates if samfeatureflags.sloop],
}
