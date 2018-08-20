local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if (!utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom)) then
{
        kind: "Deployment",
        spec: {
                replicas: 1,
                template: {
                        spec: {
                                hostNetwork: true,
                                containers: [
                                        {
                                                name: "temp-secret-samcontrol-deployer",
                                                image: samimages.hypersam,
                                                command: configs.filter_empty([
                                                        "/sam/samcontrol-deployer",
                                                        "--config=/config/tempsecretsamcontroldeployer.json",
                                                        configs.sfdchosts_arg,
                                                ]),
                                                volumeMounts: configs.filter_empty([
                                                        configs.maddog_cert_volume_mount,
                                                        configs.kube_config_volume_mount,
                                                        configs.sfdchosts_volume_mount,
                                                        configs.config_volume_mount,
                                                        configs.cert_volume_mount,
                                                ]),
                                                env: [
                                                        configs.kube_config_env,
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
                                volumes: configs.filter_empty([
                                        configs.sfdchosts_volume,
                                        configs.maddog_cert_volume,
                                        configs.cert_volume,
                                        configs.kube_config_volume,
                                        configs.config_volume("temp-secret-samcontrol-deployer"),
                                ]),
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
                                        name: "temp-secret-samcontrol-deployer",
                                        apptype: "control",
                                } + configs.ownerLabel.sam,
                        },
                },
        },
        apiVersion: "extensions/v1beta1",
        metadata: {
                labels: {
                        name: "temp-secret-samcontrol-deployer",
                } + configs.ownerLabel.sam,
                name: "temp-secret-samcontrol-deployer",
                namespace: "sam-system",
        },
} else "SKIP"
