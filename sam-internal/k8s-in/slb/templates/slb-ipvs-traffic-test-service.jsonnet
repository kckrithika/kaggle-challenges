local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbflights = import "slbflights.jsonnet";
local slbports = import "slbports.jsonnet";

local canaryName = "slb-ipvs";
local serviceName = "slb-ipvs-traffic-test-service";
local vipName = canaryName;

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=9107,
        lbType="tcp",
        name=canaryName + "-port",
        nodePort=slbports.slb.slbIpvsTrafficTestPort,
    ) { healthPath: "/" },
];

if slbflights.enableIpvsTrafficTest then
   slbbaseservice.slbCanaryBaseService(canaryName, canaryPortConfig, serviceName, vipName) {
} else "SKIP"
