local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
{
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        image: samimages.hypersam,
                        command: [
                                     "/sam/watchdog",
                                     "-role=ETCD",
                                     "-watchdogFrequency=5s",
                                     "-alertThreshold=3m",
                                     "-watchDogKind=" + $.kind,
                                 ]
                                 + samwdconfig.shared_args
                                 + (if configs.kingdom == "prd" then ["-emailFrequency=48h"] else ["-emailFrequency=12h"]),
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            configs.config_volume_mount,
                        ] + (if configs.kingdom == "prd" then [configs.kube_config_volume_mount] else [])),
                        env: configs.filter_empty([] + (if configs.kingdom == "prd" then [configs.kube_config_env] else [])),
                        name: "watchdog",
                        resources: {
                            requests: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                            limits: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                        },
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.config_volume("watchdog"),
                ] + (if configs.kingdom == "prd" then [configs.kube_config_volume] else [])),
                # We are still using flannel in minion pools in public cloud, so we need to keep an eye on etcd that holds its config
                # Everywhere else, we just care about the KubeApi etcd nodes
                nodeSelector: if utils.is_public_cloud(configs.kingdom) then {
                    etcd_installed: "true",
                } else {
                    etcd_installed: "true",
                    master: "true",
                },
            },
            metadata: {
                labels: {
                    app: "watchdog-etcd",
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
            name: "watchdog-etcd",
        } + configs.ownerLabel.sam,
        name: "watchdog-etcd",
    },
}
