local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = import "slbconfig.jsonnet";

local script = "/config/slb-journald-killer-journald-hash.sh";

// mgrass: 2019-01-25: journald killer for issue discussed in https://computecloud.slack.com/archives/C4BM25SK0/p1548450935086900
if configs.estate == "phx-sam" then configs.deploymentBase("slb") {

      metadata: {
          labels: {
              name: "dummy-image-promotion",
          } + configs.ownerLabel.slb,
          name: "dummy-image-promotion",
          namespace: "sam-system",
      },
      spec+: {
        replicas: 0,
        template: {
            metadata: {
                labels: {
                    name: "dummy-image-promotion",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                containers: [
                    {
                        name: "image-promotiuon",
                        image: "2778-29ee2fa3a4532165211b8adae39ecf04c451a410",
                    },
                ],
            }
        },
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 1,
            },
        },
        minReadySeconds: 30,
      },
} else
    "SKIP"
