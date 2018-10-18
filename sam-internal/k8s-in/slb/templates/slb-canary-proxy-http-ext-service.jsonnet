local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbflights = import "slbflights.jsonnet";

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
] + (if configs.estate == "iad-sam" then [
    slbportconfiguration.newPortConfiguration(
        port=443,
        targetPort=portconfigs.slb.canaryServiceProxyHttpPort,
        lbType="http",
        name="slb-canary-proxy-https-port",
    ) {
        tls: true,
        healthpath: "/health",
        healthprotocol: "http",
        tlscertificate: "secret_service:SlbPublicCanary:" + configs.kingdom + "-cert",
        tlskey: "secret_service:SlbPublicCanary:" + configs.kingdom + "-key",
        },
] else []);

if slbconfigs.isProdEstate && configs.estate != "prd-sam" then
    slbbaseservice.slbCanaryBaseService(canaryName, canaryPortConfig, serviceName, vipName) {
} else "SKIP"
