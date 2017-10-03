local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
{
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                "volumes": configs.filter_empty([
                    {
                        "hostPath": {
                            "path": "/var/lib/puppet/state"
                        },
                        "name": "last-run-summary"
                    },
                    {
                        "hostPath": {
                            "path": "/etc/puppet"
                        },
                        "name": "afw-build"
                    },
                    configs.config_volume("watchdog"),
                ]),
                containers: [
                    {
                        image: samimages.hypersam,
                        command: [
                            "/sam/watchdog",
                            "-role=PUPPET",
                            "-watchdogFrequency=15m",
                            "-alertThreshold=1000h",
                            "-emailFrequency=1000h",
                        ]
                        + samwdconfig.shared_args,
                        # Please add all new flags and snooze instances to ../configs-sam/watchdog-config.jsonnet
                        name: "watchdog",
                        resources: {
                            requests: {
                                cpu: "0.5",
                                memory: "300Mi"
                            },
                            limits: {
                                cpu: "0.5",
                                memory: "300Mi"
                            }
                        },
                         "volumeMounts": configs.filter_empty([
                            {
                               "mountPath": "/var/lib/puppet/state",
                               "name": "last-run-summary"
                            },
                            {
                               "mountPath": "/etc/puppet",
                               "name": "afw-build"
                            },
                            configs.config_volume_mount,
                         ]),
                    }
                ],
            },
            metadata: {
                labels: {
                    app: "watchdog-puppet",
                    apptype: "monitoring",
                    daemonset: "true",
                }
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-puppet"
        },
        name: "watchdog-puppet"
    }
}
