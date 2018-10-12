local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local canary = import "slb-canary-base-deployment.libsonnet";

if configs.estate == "prd-sdc" || slbconfigs.isProdEstate then
    canary.slbCanaryBaseDeployment(
        canaryName="slb-bravo",
        ports=[9090, 9091, 9092],
        tlsPorts=[portconfigs.slb.canaryServiceTlsPort],
        replicas=1,
) {
} else "SKIP"
