local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbflights = import "slbflights.jsonnet";

local canaryName = "slb-canary-proxy-tcp";
local serviceName = canaryName + "-service";
local vipName = canaryName;

local proxyProtocolPortConfig = if slbflights.proxyProtocolCanaryEnabled then [
    slbportconfiguration.newPortConfiguration(
        port=8081,
        lbType="tcp",
        name=canaryName + "-proxyproto-port",
    ) {
        healthprotocol: "tcp",
        proxyprotocol: true,
    },
] else [];

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=portconfigs.slb.canaryServiceProxyTcpPort,
        lbType="tcp",
        name=canaryName + "-port",
        nodePort=portconfigs.slb.canaryServiceProxyTcpNodePort,
    ) { healthPath: "/" },
] + proxyProtocolPortConfig;

if configs.estate == "prd-sdc" || slbconfigs.slbInProdKingdom then
   slbbaseservice.slbCanaryBaseService(canaryName, canaryPortConfig, serviceName, vipName) {
} else "SKIP"
