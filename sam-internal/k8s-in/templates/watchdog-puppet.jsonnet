local configs = import "config.jsonnet";
local wdconfig = import "wdconfig.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-samtest" || configs.estate == "prd-sam" || configs.estate == "prd-sdc" then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                "volumes": [
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
                    }
                ],
                containers: [
                    {
                        image: configs.watchdog,
                        command: [
                            "/sam/watchdog",
                            "-role=PUPPET",
                            "-watchdogFrequency=5m",
                            "-alertThreshold=48h",
                            "-emailFrequency=168h",
                        ]
                        + wdconfig.shared_args,
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
                         "volumeMounts": [
                            {
                               "mountPath": "/var/lib/puppet/state",
                               "name": "last-run-summary"
                            },
                            {
                               "mountPath": "/etc/puppet",
                               "name": "afw-build"
                            }
                         ]
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
} else "SKIP"
