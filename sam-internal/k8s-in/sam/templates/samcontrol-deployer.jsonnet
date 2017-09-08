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
                         volumeMounts: configs.cert_volume_mounts + [
                           configs.cert_volume_mount,
                           configs.kube_config_volume_mount,
                           configs.config_volume_mount,
                         ],
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
                volumes: configs.cert_volumes + [
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("samcontrol-deployer"),
                ],
                nodeSelector: {
                    pool: configs.estate
                } +
                if configs.kingdom == "prd" then {
                    master: "true"
                } else {}
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
        name: "samcontrol-deployer"
    }
}
