local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

# This is a watchdog for SAM's hosts that request maddog certs

{
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-maddogcert",
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=MADDOGCERT",
                                     "-watchdogFrequency=10m",
                                     "-alertThreshold=30m",
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
                        env: configs.filter_empty([] + (if configs.kingdom == "prd" then [configs.kube_config_env] else [])),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.config_volume("watchdog"),
                    configs.cert_volume,
                    configs.maddog_cert_volume,
                ] + (if configs.kingdom == "prd" then [configs.kube_config_volume] else [])),
            },
            metadata: {
                labels: {
                    name: "watchdog-maddogcert",
                    apptype: "monitoring",
                    daemonset: "true",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-maddogcert",
        } + configs.ownerLabel.sam,
        name: "watchdog-maddogcert",
    },
}
