local configs = import "config.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet");
local slbflights = import "slbflights.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbports = import "slbports.jsonnet";
local dnsRegisterInGkeEnabled = (configs.estate == "gsf-core-devmvp-sam2-samtest");

if dnsRegisterInGkeEnabled then configs.deploymentBase("slb") {
      metadata: {
          labels: {
            name: "slb-external-dns",
            sam_app: "devmvp-dns-register",
          } + configs.pcnEnableLabel,
          name: "slb-external-dns",
          namespace: "sam-system",
      },
      spec+: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-external-dns",
                } + configs.pcnEnableLabel,
                namespace: "sam-system",
            },
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "slb-external-dns",
                        image: "gcr.io/gsf-core-devmvp-sam2/rgade/external-dns@sha256:f395ba72e53d9c1e8851461af82da3bd215240bacddde3e7843058dc5cea76c2",
                        args: [
                                 "--source=service",
                                 "--google-project=netsec-222617",
                                 "--registry=txt",
                                 "--txt-owner-id=slb",
                                 "--provider=google",
                                 "--domain-filter=sfdc.net.",
                                 "--log-level=debug",
                             ],
                        volumeMounts: [{
                                      mountPath: "/var/secrets/google",
                                      name: "google-cloud-key",
                                    }],
                        env: [
                                {
                                    name: "GOOGLE_APPLICATION_CREDENTIALS",
                                    value: "/var/secrets/google/key.json",
                                  },
                                  configs.pcn_kingdom_env,
                                  configs.pcn_estate_env,
                                  configs.pcn_kube_config_env,
                            ],
                    },
                ],
                volumes+: [{
                               name: "google-cloud-key",
                               secret: {
                                 secretName: "cloud-dns-key",
                               },
                            }],
                nodeSelector: {
                    pool: configs.estate,
                },
            } + configs.serviceAccount,
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
    } else "SKIP"
