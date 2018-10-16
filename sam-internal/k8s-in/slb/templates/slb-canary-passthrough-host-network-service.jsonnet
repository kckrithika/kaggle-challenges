local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbflights = import "slbflights.jsonnet";

local canaryName = "slb-canary-passthrough-host-network";
local serviceName = canaryName + "-service";
local vipName = "slb-canary-pt-host-nw";

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=portconfigs.slb.canaryServicePassthroughHostNetworkPort,
        lbType="dsr",
        name=canaryName + "-port",
        nodePort=portconfigs.slb.canaryServicePassthroughHostNetworkNodePort,
    ) {
        healthpath: "/health",
    },
];

if configs.estate == "prd-sdc" || slbconfigs.slbInProdKingdom then
    slbbaseservice.slbCanaryBaseService(canaryName, canaryPortConfig, serviceName, vipName) {

    // TODO: this is vestigial and should be removed.
    [if slbflights.useDeprecatedCanaryDifferences then "metadata"]+: {
        labels+: {
            "slb.sfdc.net/type": "none",
        },
    },
} else "SKIP"
