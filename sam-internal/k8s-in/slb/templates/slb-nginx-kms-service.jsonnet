local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbflights = import "slbflights.jsonnet";
local utils = import "util_functions.jsonnet";

local canaryName = slbconfigs.hsmNginxProxyName;
local serviceName = canaryName + "-service";
local vipName = canaryName;

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=443,
        lbType="dsr",
        name=canaryName + "-port",
        nodePort=443,
    ),
];

if configs.estate == "prd-sdc" then {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
      name: serviceName,
      namespace: "sam-system",
      labels: {
        app: serviceName,
      } + configs.ownerLabel.slb,
      annotations: {
        "slb.sfdc.net/name": vipName,
        "slb.sfdc.net/portconfigurations": slbportconfiguration.portConfigurationToString(canaryPortConfig),
      },
    },

    spec: {
      ports: [
        {
          name: c.name,
          port: c.port,
          protocol: "TCP",
          targetPort: c.targetport,
        }
             for c in canaryPortConfig
],
      selector: {
        name: canaryName,
      },
      type: "NodePort",
    },
} else "SKIP"
