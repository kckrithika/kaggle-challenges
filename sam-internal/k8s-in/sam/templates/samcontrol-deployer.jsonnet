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
                        command: [
                           "/sam/samcontrol-deployer",
                           "--config=/config/samcontroldeployer.json",
                           ],
                         volumeMounts: configs.filter_empty([
                           configs.hosts_volume_mount,
                           configs.maddog_cert_volume_mount,
                           configs.cert_volume_mount,
                           configs.kube_config_volume_mount,
                           configs.config_volume_mount,
                         ]),
                         env: [
                           configs.kube_config_env,
                         ],
                         livenessProbe: {
                           "httpGet": {
                             "path": "/",
                             "port": 9099
                           },
                           "initialDelaySeconds": 2,
                           "periodSeconds": 10,
                           "timeoutSeconds": 10
                        }
                    }
                ],
                volumes: configs.filter_empty([
                    configs.hosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("samcontrol-deployer"),
                ]),
                nodeSelector: {
                } +
                if configs.kingdom == "prd" then {
                    master: "true"
                } else {
                     pool: configs.estate
                },
            },
            metadata: {
                labels: {
                    name: "samcontrol-deployer",
                    apptype: "control"
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "samcontrol-deployer"
        },
        name: "samcontrol-deployer",
        namespace: "sam-system"
    }
}
