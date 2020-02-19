local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sloop = import "configs/sloop-config.jsonnet";

local estatePortMapping(estate) = {
  name: "sloop-" + estate,
  port: sloop.estateConfigs[estate].hostPort,
  protocol: "TCP",
  targetPort: sloop.estateConfigs[estate].containerPort,
};

local estatePortAnnotations(estate) = {
  port: sloop.estateConfigs[estate].hostPort,
  targetport: sloop.estateConfigs[estate].containerPort,
  nodeport: 0,
  lbtype: "",
  reencrypt: false,
  sticky: 0,
};

if samfeatureflags.sloop then {
  kind: "Service",
  apiVersion: "v1",
  metadata: {
    name: "sloop",
    namespace: "sam-system",
    labels: {
      app: "sloop",
    } + configs.ownerLabel.sam,
    annotations: {
      "slb.sfdc.net/name": "sloop",
      "slb.sfdc.net/portconfigurations": std.toString(
        [estatePortAnnotations(est) for est in samfeatureflags.sloopEstates[configs.estate]]
      ),
    },
  },
  spec: {
    ports: [estatePortMapping(est) for est in samfeatureflags.sloopEstates[configs.estate]],
    selector: {
      app: "sloopds",
    },
  },
} else "SKIP"
