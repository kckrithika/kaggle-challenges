local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
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
                        volumeMounts+: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                        ]) + (if configs.kingdom == "prd" then [
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
                    } + configs.containerInPCN,
                ] + if utils.is_pcn(configs.kingdom) then [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "etcd-client",
                        image: "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-devmvp/tnrp/sam/etcd",
                        command: configs.filter_empty([
                            "./etcd",
                            "--listen-peer-urls=http://0.0.0.0:2380",
                            "--listen-client-urls=http://0.0.0.0:2379",
                            "--advertise-client-urls=http://0.0.0.0:2379",
                            "--initial-cluster-state=new",
                        ]),
                    } + configs.containerInPCN,
                ] else [],
                volumes+: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("samcontrol-deployer"),
                ]) + (if configs.kingdom == "prd" then [
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
            } + configs.serviceAccount,
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
        } + configs.ownerLabel.sam
        + configs.pcnEnableLabel,
        name: "samcontrol-deployer",
        namespace: "sam-system",
    },
}
