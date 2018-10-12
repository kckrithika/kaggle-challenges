local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local canary = import "slb-canary-base-deployment.libsonnet";

if configs.estate == "prd-sdc" || slbconfigs.slbInProdKingdom then
    canary.slbCanaryBaseDeployment(
        canaryName="slb-canary-passthrough-host-network",
        ports=[portconfigs.slb.canaryServicePassthroughHostNetworkPort],
        // TODO: unclear why this is special-cased for prd-samtest.
        replicas=if configs.estate == "prd-samtest" then 1 else 2,
        hostNetwork=true,
) {
} else "SKIP"
