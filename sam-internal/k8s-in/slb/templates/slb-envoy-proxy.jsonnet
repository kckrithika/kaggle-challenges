local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-envoy-proxy" };
local portconfigs = import "portconfig.jsonnet";
local slbports = import "slbports.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-envoy-proxy" };
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: "slb-nginx-config-b" };
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-envoy-proxy" };
local slbbaseproxy = (import "slb-base-proxy.libsonnet") + { dirSuffix:: slbconfigs.envoyProxyConfigDeploymentName };

local certDirs = ["cert1", "cert2"];

local envoyAffinity = {
    podAntiAffinity: {
        requiredDuringSchedulingIgnoredDuringExecution: [{
            labelSelector: {
                matchExpressions: [{
                    key: "name",
                    operator: "In",
                    values: [
                        "slb-ipvs",
                        "slb-envoy-proxy",
                    ],
                }],
            },
            topologyKey: "kubernetes.io/hostname",
        }],
    },
    // Ensure that the envoy pods don't land on nodes allocated to ipvs,
    // nor on nodes allocated to nginx-config-b.
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

if (slbconfigs.isProdEstate || configs.estate == "prd-sdc") && slbflights.deploySLBEnvoyConfig then
  slbbaseproxy.slbBaseProxyDeployment("envoy", slbconfigs.envoyProxyConfigDeploymentName, 1, envoyAffinity, slbimages.slbenvoy) {
    spec+: {
        strategy+: {
            rollingUpdate+: {
                maxSurge: if configs.estate == "prd-sam" then 1 else 0,
            },
        },
        minReadySeconds: 30,
    },
  }
else "SKIP"
