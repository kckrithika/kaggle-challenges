local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbflights = import "slbflights.jsonnet";

local labelSelector = "slb-nginx-config-b";
local vipName = "slb-upstream-status";
local serviceName = vipName + "-service";

local portConfig = [
    slbportconfiguration.newPortConfiguration(
        port=80,
        lbType="http",
        targetPort=12080,
        name="slb-upstream-status-http-port"
    ) { healthpath: "/" },
];

if slbimages.phaseNum <= 3 then
    slbbaseservice.slbCanaryBaseService(labelSelector, portConfig, serviceName, vipName) {
} else "SKIP"
