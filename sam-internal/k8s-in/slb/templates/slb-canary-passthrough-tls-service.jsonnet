local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbflights = import "slbflights.jsonnet";

local canaryName = "slb-canary-passthrough-tls";
local serviceName = canaryName + "-service";
local vipName = "slb-canary-pt-tls";

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=portconfigs.slb.canaryServicePassthroughTlsPort,
        lbType="dsr",
        name=canaryName + "-port",
    ) { healthpath: "/health" },
];

if slbconfigs.slbInProdKingdom then
    slbbaseservice.slbCanaryBaseService(canaryName, canaryPortConfig, serviceName, vipName) {
} else "SKIP"
