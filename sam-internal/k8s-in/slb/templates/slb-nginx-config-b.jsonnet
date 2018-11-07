local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-nginx-config-b" };
local portconfigs = import "portconfig.jsonnet";
local slbports = import "slbports.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-nginx-config-b" };
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: "slb-nginx-config-b" };
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-nginx-config-b" };
local slbbasenginxproxy = (import "slb-base-nginx-proxy.libsonnet") + { dirSuffix:: slbconfigs.nginxProxyName };

local certDirs = ["cert1", "cert2"];

local nginxAffinity = (if slbflights.nginxPodFloat then {
    podAntiAffinity: {
        requiredDuringSchedulingIgnoredDuringExecution: [{
            labelSelector: {
                matchExpressions: [{
                    key: "name",
                    operator: "In",
                    values: [
                        "slb-ipvs",
                        "slb-nginx-config-b",
                    ],
                }],
            },
            topologyKey: "kubernetes.io/hostname",
        }],
    },
    // Ensure that the floating nginx pods don't land on nodes allocated to ipvs.
    // This is a stopgap solution until ipvs is made to float as well.
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
} else {
    podAntiAffinity: {
        requiredDuringSchedulingIgnoredDuringExecution: [{
            labelSelector: {
                matchExpressions: [{
                    key: "name",
                    operator: "In",
                    values: [
                        slbconfigs.nginxProxyName,
                    ],
                }],
            },
            topologyKey: "kubernetes.io/hostname",
        }],
    },
    nodeAffinity: {
        requiredDuringSchedulingIgnoredDuringExecution: {
            nodeSelectorTerms: [{
                matchExpressions: [{
                    key: "slb-service",
                    operator: "In",
                    values: ["slb-nginx-b"],
                }],
            }],
        },
    },
});

local nginxReloadSentinelParam = "--control.nginxReloadSentinel=" + slbconfigs.slbDir + "/nginx/config/nginx.marker";

if slbconfigs.isSlbEstate then
  slbbasenginxproxy.slbBaseNginxProxyDeployment(slbconfigs.nginxProxyName, slbconfigs.nginxConfigReplicaCount, nginxAffinity, slbimages.slbnginx) {
    spec+: {
        strategy+: {
            rollingUpdate+: {
                maxSurge: if configs.estate == "prd-sam" then 1 else 0,
            },
        },
    },
  }
else "SKIP"
