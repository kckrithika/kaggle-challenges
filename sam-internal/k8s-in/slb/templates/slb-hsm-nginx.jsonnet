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
    podAntiAffinity: {
        requiredDuringSchedulingIgnoredDuringExecution: [{
            labelSelector: {
                matchExpressions: [{
                    key: "name",
                    operator: "In",
                    values: [
                        "slb-ipvs",
                        slbconfigs.hsmNginxProxyName,
                    ],
                }],
            },
            topologyKey: "kubernetes.io/hostname",
        }],
    },
    // Ensure that the floating nginx pods don't land on nodes allocated to ipvs.
    nodeAffinity: {
        requiredDuringSchedulingIgnoredDuringExecution: {
            nodeSelectorTerms: [{
                matchExpressions: [{
                    key: "slb-service",
                    operator: "NotIn",
                    values: ["slb-ipvs"],
                }],
            }],
        },
    },
};

// The number of replicas to run in the cluster.
local replicas = 2;

local certDirs = ["cert1", "cert2"];

if slbflights.hsmCanaryEnabled && !slbflights.disableCanaryVIPs then
    slbbasenginxproxy.slbBaseNginxProxyDeployment(
      slbconfigs.hsmNginxProxyName,
      replicas,
      hsmNginxAffinity,
      slbimages.hsmnginx,
      proxyFlavor="hsm",
) {}
else "SKIP"
