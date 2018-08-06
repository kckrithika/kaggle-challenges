local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.sdpv1 then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-sdp",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=SDP",
                                     "-watchdogFrequency=10s",
                                     "-alertThreshold=300s",
                                     "-emailFrequency=24h",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.shared_args,
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.config_volume_mount,
                            configs.cert_volume_mount,
                            configs.maddog_cert_volume_mount,
                        ] + (if configs.kingdom == "prd" then [configs.kube_config_volume_mount] else [])),
                        [if configs.kingdom == "prd" then "env"]: [configs.kube_config_env],
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.config_volume("watchdog"),
                    configs.cert_volume,
                    configs.maddog_cert_volume,
                ] + (if configs.kingdom == "prd" then [configs.kube_config_volume] else [])),
                nodeSelector: {
                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "watchdog-sdp",
                    apptype: "monitoring",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "watchdog-sdp",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-sdp",
        } + configs.ownerLabel.sam,
        name: "watchdog-sdp",
    },
} else "SKIP"
