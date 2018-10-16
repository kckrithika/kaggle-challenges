local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local canary = import "slb-canary-base-deployment.libsonnet";

// The name of this canary suggests that it should be using host networking, but it was not :(.
// Phase it in.
local hostNetworkEnabled = if slbflights.useDeprecatedCanaryDifferences then false else true;

if configs.estate == "prd-sdc" || slbconfigs.slbInProdKingdom then
    canary.slbCanaryBaseDeployment(
        canaryName="slb-canary-proxy-tcp-host",
        ports=[9120],
        replicas=2,
        hostNetwork=hostNetworkEnabled,
) {
} else "SKIP"
