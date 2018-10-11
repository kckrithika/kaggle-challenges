local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";

local canaryName = "slb-canary";
local serviceName = canaryName + "-service";
local vipName = serviceName;

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=portconfigs.slb.canaryServicePort,
        lbType="dsr",
        name="slb-canary-port",
        nodePort=portconfigs.slb.canaryServiceNodePort,
    ) { healthpath: "/health" },

    slbportconfiguration.newPortConfiguration(
        port=portconfigs.slb.canaryServiceTlsPort,
        lbType="dsr",
        name="slb-canary-tls",
        nodePort=portconfigs.slb.canaryServiceTlsNodePort,
    ) { healthpath: "/health" },
];

if configs.estate == "prd-sdc" || slbconfigs.isProdEstate then
    slbbaseservice.slbCanaryBaseService(canaryName, canaryPortConfig, serviceName, vipName) {
} else "SKIP"
