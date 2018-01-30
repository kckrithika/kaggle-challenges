local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
{
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "samcontrol-deployer",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                           "/sam/samcontrol-deployer",
                           "--config=/config/samcontroldeployer.json",
                           configs.sfdchosts_arg,
                           ]) + (if (configs.kingdom == "prd") then [
                                    "--tokenfile=/var/secrets/git/token.txt",
                                    "--auto-deployment-frequency=6h",
                                    "--auto-deployment-offset=3h",
                              ] else []),
                         volumeMounts: configs.filter_empty([
                           configs.sfdchosts_volume_mount,
                           configs.maddog_cert_volume_mount,
                           configs.cert_volume_mount,
                           configs.kube_config_volume_mount,
                           configs.config_volume_mount,
                         ]) + (if configs.kingdom == "prd" then [
                             {
                                 mountPath: "/var/token",
                                 name: "token",
                                 readOnly: true,
                             },
                         ] else []),
                         env: [
                           configs.kube_config_env,
                         ],
                         livenessProbe: {
                           httpGet: {
                             path: "/",
                             port: 9099,
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
                if configs.kingdom == "prd" then {
                    master: "true",
                } else {
                     pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "samcontrol-deployer",
                    apptype: "control",
                },
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "samcontrol-deployer",
        },
        name: "samcontrol-deployer",
        namespace: "sam-system",
    },
}
