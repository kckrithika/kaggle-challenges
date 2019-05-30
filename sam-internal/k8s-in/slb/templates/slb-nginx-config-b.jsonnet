local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-nginx-config-b" };
local portconfigs = import "portconfig.jsonnet";
local slbports = import "slbports.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-nginx-config-b" };
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: "slb-nginx-config-b" };
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-nginx-config-b" };
local slbbaseproxy = (import "slb-base-proxy.libsonnet") + { dirSuffix:: slbconfigs.nginxProxyName };

local certDirs = ["cert1", "cert2"];

local nginxAffinity = {
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
};
local nginxReloadSentinelParam = "--control.nginxReloadSentinel=" + slbconfigs.slbDir + "/nginx/config/nginx.marker";

if slbconfigs.isSlbEstate then
  slbbaseproxy.slbBaseProxyDeployment("nginx", slbconfigs.nginxProxyName, slbconfigs.nginxConfigReplicaCount, nginxAffinity, slbimages.slbnginx) {
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
