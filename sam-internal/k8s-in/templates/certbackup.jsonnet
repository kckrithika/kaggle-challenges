local configs = import "config.jsonnet";
# Yeah, I know this is not a watchdog.  Will fix with a refactor
local wdconfig = import "wdconfig.jsonnet";

if configs.estate == "prd-samdev" then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        # Todo: switch to hypersam from tnrp when it is merged
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/thargrove/hypersam:20170420_153626.f6ca1d3.dirty.thargrove-ltm1",
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
} else "SKIP"
