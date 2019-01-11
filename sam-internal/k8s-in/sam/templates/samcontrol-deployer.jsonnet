local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
configs.deploymentBase("sam") {
    spec+: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "samcontrol-deployer",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                            "/sam/samcontrol-deployer",
                            "--config=/config/samcontroldeployer.json",
                            configs.sfdchosts_arg,
                        ]),
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                        ] + (if configs.kingdom == "prd" then [
                                  {
                                      mountPath: "/var/token",
                                      name: "token",
                                      readOnly: true,
                                  },
                              ] else []),
                        livenessProbe: {
                            httpGet: {
                                path: "/",
                                port: 9099,
                            },
                            initialDelaySeconds: 20,
                            periodSeconds: 10,
                            timeoutSeconds: 10,
                        },
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("samcontrol-deployer"),
                ] + (if configs.kingdom == "prd" then [
                          {
                              secret: {
                                  secretName: "git-token",
                              },
                              name: "token",
                          },
                      ] else []),
                nodeSelector: {
                              } +
                              if configs.kingdom == "prd" || configs.kingdom == "xrd" then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
            },
            metadata: {
                labels: {
                    name: "samcontrol-deployer",
                    apptype: "control",
                } + configs.ownerLabel.sam,
            },
        },
    },
    metadata+: {
        labels: {
            name: "samcontrol-deployer",
        } + configs.ownerLabel.sam,
        name: "samcontrol-deployer",
        namespace: "sam-system",
    },
}
