local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
# Yeah, I know this is not a watchdog.  Will fix with a refactor
local wdconfig = import "samwdconfig.jsonnet";

{
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        # Todo: switch to hypersam from tnrp when it is merged
                        image: samimages.hypersam,
                        command: [
                            "/sam/certbackup.sh"
                        ],
                        name: "certbackup",
                        volumeMounts: [
                          wdconfig.cert_volume_mount,
                          wdconfig.kube_config_volume_mount,
                       ],
                       env: [
                          {
                             "name": "KUBECONFIG",
                             "value": configs.configPath
                          }
                       ]
                    }
                ],
                volumes: [
                    wdconfig.cert_volume,
                    wdconfig.kube_config_volume,
                ],
            },
            metadata: {
                labels: {
                    name: "certbackup",
                    daemonset: "true",
                }
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "certbackup"
        },
        name: "certbackup"
    }
}
