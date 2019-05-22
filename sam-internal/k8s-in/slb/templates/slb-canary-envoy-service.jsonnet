local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbimages = import "slbimages.jsonnet";
local slbflights = import "slbflights.jsonnet";
local commonutils = import "util_functions.jsonnet";

local canaryName = "slb-canary-envoy";
local serviceName = canaryName + "-svc";
local vipName = serviceName;

local portConfig = [
    slbportconfiguration.newPortConfiguration(
        port=9090,
        lbType="tcp",
        name="slb-canary-envoy-port",
    ),
    slbportconfiguration.newPortConfiguration(
        port=9091,
        lbType="http",
        name="slb-canary-envoy-port-1",
    ),
    slbportconfiguration.newPortConfiguration(
        port=9092,
        lbType="dsr",
        name="slb-canary-envoy-2",
    ),
    slbportconfiguration.newPortConfiguration(
        port=portconfigs.slb.canaryServiceTlsPort,
        lbType="dsr",
        name="slb-canary-envoy-port-3",
    ),
];

local cnames = [{ cname: "canary-envoy-" + commonutils.string_replace(configs.estate, "_", "-") + ".slb.sfdc.net" }];

if configs.estate == "prd-sdc" then
    slbbaseservice.slbCanaryBaseService(canaryName, portConfig, serviceName, vipName, cnames) {
} else "SKIP"
