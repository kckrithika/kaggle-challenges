local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbimages = import "slbimages.jsonnet";
local slbflights = import "slbflights.jsonnet";
local commonutils = import "util_functions.jsonnet";

local canaryName = "slb-bravo";
local serviceName = canaryName + "-svc";
local vipName = serviceName;

local bravoPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=9090,
        lbType="tcp",
        name="slb-bravo-port",
        nodePort=portconfigs.slb.bravoServiceNodePort,
    ),
    slbportconfiguration.newPortConfiguration(
        port=9091,
        lbType="http",
        name="slb-bravo-port-1",
        nodePort=portconfigs.slb.bravoServiceNodePort1,
    ),
    slbportconfiguration.newPortConfiguration(
        port=9092,
        lbType="dsr",
        name="slb-bravo-port-2",
        nodePort=portconfigs.slb.bravoServiceNodePort2,
    ),
    slbportconfiguration.newPortConfiguration(
        port=portconfigs.slb.canaryServiceTlsPort,
        lbType="dsr",
        name="slb-bravo-port-3",
        nodePort=portconfigs.slb.bravoServiceNodePort3,
    ),
];

local cnames = [{ cname: "bravo-" + commonutils.string_replace(configs.estate, "_", "-") + ".slb.sfdc.net" }];

if slbconfigs.isProdEstate then
    slbbaseservice.slbCanaryBaseService(canaryName, bravoPortConfig, serviceName, vipName, cnames) {
} else "SKIP"
