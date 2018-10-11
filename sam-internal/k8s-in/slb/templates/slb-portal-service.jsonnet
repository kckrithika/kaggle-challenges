local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";

local deploymentName = "slb-portal";
local serviceName = deploymentName + "-service";
local vipName = serviceName;

local portalPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=portconfigs.slb.slbPortalServicePort,
        lbType="http",
        name="slb-portal-port",
        nodePort=portconfigs.slb.slbPortalServiceNodePort,
    ),
];

if slbconfigs.isSlbEstate && configs.estate != "prd-samtest" then
    slbbaseservice.slbCanaryBaseService(deploymentName, portalPortConfig, serviceName, vipName) {
} else "SKIP"
