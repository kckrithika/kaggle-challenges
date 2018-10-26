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
        nodePort=0,
    ),
];

if configs.estate == "prd-sdc" then
    slbbaseservice.slbCanaryBaseService(canaryName, canaryPortConfig, serviceName, vipName) {
} else "SKIP"
