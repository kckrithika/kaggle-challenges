local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbflights = import "slbflights.jsonnet";
local utils = import "util_functions.jsonnet";

local canaryName = "slb-canary-hsm";
local serviceName = canaryName + "-service";
local vipName = canaryName;

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=443,
        lbType="http",
        name=canaryName + "-port",
        nodePort=0,
    ) {
        tls: true,
        reencrypt: true,
    },
];

local cnames = if configs.estate == "prd-sam" then [] else [{ cname: "kms-" + configs.kingdom + ".slb.sfdc.net" }];

if slbconfigs.hsmNginxEnabledEstate then
    slbbaseservice.slbCanaryBaseService("slb-canary-proxy-http", canaryPortConfig, serviceName, vipName, cnames) {
} else "SKIP"
