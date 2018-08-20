local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-samtest" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "host-repair-scheduler",
        } + configs.ownerLabel.sam,
        name: "host-repair-scheduler",
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "host-repair-scheduler",
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "host-repair-scheduler",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
            spec: {
                containers: [{
                    name: "host-repair-scheduler",
                    image: samimages.hypersam,
                    command: [
                        "/sam/host-repair-scheduler",
                        "--config=/config/host-repair-scheduler.json",
                        "--hostsConfigFile=/sfdchosts/hosts.json",
                        "-v=0",
                    ],
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
                }],
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    configs.kube_config_volume,
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    configs.config_volume("host-repair-scheduler"),
                ]),
                hostNetwork: true,
                nodeSelector: {
                    master: "true",
                },
            },
        },
    },
} else "SKIP"
