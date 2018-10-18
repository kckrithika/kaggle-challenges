local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local canary = import "slb-canary-base-deployment.libsonnet";

if configs.estate == "prd-sdc" || slbconfigs.slbInProdKingdom then
    canary.slbCanaryBaseDeployment(
        canaryName="slb-canary-proxy-tcp-host",
        ports=[9120],
        replicas=2,
        hostNetwork=true,
) {
} else "SKIP"
