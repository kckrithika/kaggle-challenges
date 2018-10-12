local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";

local canaryName = "slb-canary-proxy-tcp";
local serviceName = canaryName + "-service";
local vipName = canaryName;

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=portconfigs.slb.canaryServiceProxyTcpPort,
        lbType="tcp",
        name=canaryName + "-port",
        nodePort=portconfigs.slb.canaryServiceProxyTcpNodePort,
    ) { healthPath: "/" },
];

if configs.estate == "prd-sdc" || slbconfigs.slbInProdKingdom then
   slbbaseservice.slbCanaryBaseService(canaryName, canaryPortConfig, serviceName, vipName) {

    // TODO: this is vestigial and should be removed.
    metadata+: {
        labels+: {
            "slb.sfdc.net/type": "tcp",
        },
    },
} else "SKIP"
