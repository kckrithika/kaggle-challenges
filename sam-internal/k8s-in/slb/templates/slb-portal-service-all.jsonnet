local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";

local services = [
    {
        local deploymentName = "slb-portal-" + kingdomName,
        local serviceName = deploymentName + "-service",
        local vipName = serviceName,

        local portalPortConfig = [
            slbportconfiguration.newPortConfiguration(
                port=80,
                targetPort=0,
                lbType="http",
                name="slb-portal-port",
            ) {
                httpsredirectport: 443,
            },
            slbportconfiguration.newPortConfiguration(
                port=443,
                targetPort=portconfigs.slb.slbPortalServicePort,
                lbType="http",
                name="slb-portal-https-port",
            ) {
                tls: true,
            },
        ],

        local cname = { cname: deploymentName + ".slb.sfdc.net" },

        service: slbbaseservice.slbCanaryBaseService(deploymentName, portalPortConfig, serviceName, vipName, cnames=[cname]),
    }
for kingdomName in slbconfigs.prodKingdoms
];

if slbconfigs.isSlbEstate && slbconfigs.isSlbAggregatedPortalEstate then {
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: [
        service.service
for service in services
    ],
} else "SKIP"
