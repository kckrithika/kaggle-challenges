local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbflights = import "slbflights.jsonnet";

local canaryName = "slb-canary-proxy-http";
local serviceName = canaryName + "-ext-service";
local vipName = canaryName + "-ext";

local newKingdoms = ['ia2-sam', 'par-sam', 'ukb-sam', 'lo2-sam', 'lo3-sam'];
local notIsNewKingdom = configs.estate in { [e]: 1 for e in newKingdoms };

local tlscertificate = if configs.estate == "prd-samtwo" then
    // Use chained cert for canary in prd-samtwo to improve ssllabs report.
    "secret_service:slb-prd:prd-cert-chain"
else if configs.estate == "dfw-sam" || configs.estate == "ph2-sam" then
    "secret_service:SlbPublicCanary:" + configs.kingdom + "-cert"
else
    "secret_service:SlbCanarySecrets:" + configs.kingdom + "-cert";


local tlskey = if configs.estate == "prd-samtwo" then
    "secret_service:SlbPublicCanary:" + configs.kingdom + "-key"
else if configs.estate == "dfw-sam" || configs.estate == "ph2-sam" then
    "secret_service:SlbPublicCanary:" + configs.kingdom + "-key"
else
    "secret_service:SlbCanarySecrets:" + configs.kingdom + "-key";


local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=80,
        targetPort=portconfigs.slb.canaryServiceProxyHttpPort,
        lbType="http",
        name="slb-canary-proxy-http-port",
    ) { healthpath: "/health" },
    slbportconfiguration.newPortConfiguration(
        port=443,
        targetPort=portconfigs.slb.canaryServiceProxyHttpPort,
        lbType="http",
        name="slb-canary-proxy-https-port",
    ) {
        tls: true,
        healthpath: "/health",
        healthprotocol: "http",
        tlscertificate: tlscertificate,
        tlskey: tlskey,
        },
];

if slbconfigs.isProdEstate && !notIsNewKingdom && configs.estate != "prd-sam" then
    slbbaseservice.slbCanaryBaseService(canaryName, canaryPortConfig, serviceName, vipName) {
} else "SKIP"
