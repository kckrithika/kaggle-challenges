local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if (!utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom)) && configs.kingdom != "lo2" && configs.kingdom != "lo3" then
configs.deploymentBase("sam") {
        spec+: {
                replicas: 1,
                template: {
                        spec: configs.specWithKubeConfigAndMadDog {
                                hostNetwork: true,
                                containers: [
                                        configs.containerWithKubeConfigAndMadDog {
                                                name: "temp-secret-samcontrol-deployer",
                                                image: samimages.hypersam,
                                                command: configs.filter_empty([
                                                        "/sam/samcontrol-deployer",
                                                        "--config=/config/tempsecretsamcontroldeployer.json",
                                                        configs.sfdchosts_arg,
                                                ]),
                                                volumeMounts+: [
                                                        configs.sfdchosts_volume_mount,
                                                        configs.config_volume_mount,
                                                        configs.cert_volume_mount,
                                                ],
                                                livenessProbe: {
                                                        httpGet: {
                                                                path: "/",
                                                                 port: 9123,
                                                        },
                                                        initialDelaySeconds: 2,
                                                        periodSeconds: 10,
                                                        timeoutSeconds: 10,
                                                },
                                        },
                                ],
                                volumes+: [
                                        configs.sfdchosts_volume,
                                        configs.cert_volume,
                                        configs.config_volume("temp-secret-samcontrol-deployer"),
                                ],
                                nodeSelector: {
                                                          } +
                                                          if !utils.is_production(configs.kingdom) then {
                                                                  master: "true",
                                                          } else {
                                                                  pool: configs.estate,
                                                          },
                        },
                        metadata: {
                                labels: {
                                        name: "temp-secret-samcontrol-deployer",
                                        apptype: "control",
                                } + configs.ownerLabel.sam,
                        },
                },
        },
        metadata+: {
                labels: {
                        name: "temp-secret-samcontrol-deployer",
                } + configs.ownerLabel.sam,
                name: "temp-secret-samcontrol-deployer",
                namespace: "sam-system",
        },
} else "SKIP"
