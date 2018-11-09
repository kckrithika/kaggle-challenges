local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: slbconfigs.hsmNginxProxyName };
local portconfigs = import "portconfig.jsonnet";
local slbports = import "slbports.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: slbconfigs.hsmNginxProxyName };
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: slbconfigs.hsmNginxProxyName };
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: slbconfigs.hsmNginxProxyName };
local slbbasenginxproxy = (import "slb-base-nginx-proxy.libsonnet") + { dirSuffix:: slbconfigs.hsmNginxProxyName };

local hsmNginxAffinity = {
    // Currently, hsm-enabled nginx always lands on a labelled host
    // When we enable nginx floating everywhere, we should make hsm nginx float as well
    nodeAffinity: {
        requiredDuringSchedulingIgnoredDuringExecution: {
            nodeSelectorTerms: [{
                matchExpressions: [{
                    key: "slb-service",
                    operator: "In",
                    values: [slbconfigs.hsmNginxProxyName],
                }],
            }],
        },
    },
};

local certDirs = ["cert1", "cert2"];

if slbflights.hsmCanaryEnabled then
    slbbasenginxproxy.slbBaseNginxProxyDeployment(
      slbconfigs.hsmNginxProxyName,
      1,
      hsmNginxAffinity,
      slbimages.hsmnginx,
      deleteLimitOverride=(if slbflights.supportedProxiesEnabled then 150 else 0)
) {}
else "SKIP"
