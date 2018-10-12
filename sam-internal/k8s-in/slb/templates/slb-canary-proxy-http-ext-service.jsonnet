local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";

local canaryName = "slb-canary-proxy-http";
local serviceName = canaryName + "-ext-service";
local vipName = canaryName + "-ext";

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=80,
        targetPort=portconfigs.slb.canaryServiceProxyHttpPort,
        lbType="http",
        name="slb-canary-proxy-http-port",
    ) { healthpath: "/health" },
];

if slbconfigs.isProdEstate && configs.estate != "prd-sam" then
    slbbaseservice.slbCanaryBaseService(canaryName, canaryPortConfig, serviceName, vipName) {

    // TODO: this is vestigial and should be removed.
    metadata+: {
        labels+: {
            "slb.sfdc.net/type": "http",
        },
    },
} else "SKIP"
