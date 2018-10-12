local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";

local canaryName = "slb-canary-proxy-http";
local serviceName = canaryName + "-service";
local vipName = canaryName;

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=portconfigs.slb.canaryServiceProxyHttpPort,
        lbType="http",
        name="slb-canary-proxy-http-port",
        nodePort=portconfigs.slb.canaryServiceProxyHttpNodePort,
    ),
    slbportconfiguration.newPortConfiguration(
        port=443,
        lbType="http",
        name="slb-canary-proxy-https-port",
    ) { reencrypt: true, sticky: 300, healthport: 9116, hEaLtHpath: "/health", tls: true },
];

if configs.estate == "prd-sdc" || slbconfigs.isProdEstate then
    slbbaseservice.slbCanaryBaseService(canaryName, canaryPortConfig, serviceName, vipName) {

    // TODO: this is vestigial and should be removed.
    metadata+: {
        labels+: {
            "slb.sfdc.net/type": "http",
        },
    },
} else "SKIP"
