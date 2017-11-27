local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
# Yeah, I know this is not a watchdog.  Will fix with a refactor
local wdconfig = import "samwdconfig.jsonnet";

# We dont need cert backup in PRD because it is all maddog, and it is crashing
# because of a perms issue with kubectl
if configs.kingdom != "prd" then {
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
                            "/sam/certbackup.sh",
                        ],
                        name: "certbackup",
                        volumeMounts: configs.filter_empty([
                          configs.maddog_cert_volume_mount,
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                       ]),
                       env: [
                          configs.kube_config_env,
                       ],
                    },
                ],
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                ]),
            },
            metadata: {
                labels: {
                    name: "certbackup",
                    daemonset: "true",
                },
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "certbackup",
        },
        name: "certbackup",
    },
} else "SKIP"
