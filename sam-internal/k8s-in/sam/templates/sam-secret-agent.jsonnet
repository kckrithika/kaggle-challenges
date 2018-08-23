local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then configs.deploymentBase {
    spec+: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "sam-secret-agent",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                            "/sam/sam-secret-agent",
                            "--funnelEndpoint=" + configs.funnelVIP,
                            "--logtostderr=true",
                            "--disableSecurityCheck=true",
                            "--tnrpEndpoint=" + configs.tnrpArchiveEndpoint,
                            "--observeMode=" + false,
                            "--delay=300s",
                            "--keyfile=" + configs.keyFile,
                            "--certfile=" + configs.certFile,
                            "--cafile=" + configs.caFile,
                            configs.sfdchosts_arg,
                        ]),
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.cert_volume_mount,
                        ],
                        livenessProbe: {
                            httpGet: {
                                path: "/",
                                port: 9098,
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
                ],
                nodeSelector: {
                              } +
                              if configs.kingdom == "prd" then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
            },
            metadata: {
                labels: {
                    name: "sam-secret-agent",
                    apptype: "control",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
    },
    metadata+: {
        labels: {
            name: "sam-secret-agent",
        } + configs.ownerLabel.sam,
        name: "sam-secret-agent",
    },
} else "SKIP"
