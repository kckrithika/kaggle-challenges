local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";
if configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-pullrequest",
                        image: samimages.hypersam,
                        command:[
                            "/sam/watchdog",
                            "-role=PULLREQUEST",
                            "-watchdogFrequency=3m",
                            "-alertThreshold=10s",
                            "-emailFrequency=1h",
                            # Snooze prChecker for 2 weeks, @Prahlad-Joshi is on it.
                            "-snoozedAlarms=prChecker=2017/08/07"
                        ]
                        + samwdconfig.shared_args,
                        # Please add all new flags and snooze instances to ../configs-sam/watchdog-config.jsonnet
                        volumeMounts: [
                          {
                             "mountPath": "/var/token",
                             "name": "token",
                             "readOnly" : true
                          },
                          configs.config_volume_mount,
                       ],
                    }
                ],
                volumes: [
                    {
                        secret: {
                            secretName: "git-token"
                          },
                        name: "token"
                    },
                    configs.config_volume("watchdog"),
                ],
                nodeSelector: {
                    pool: configs.estate
                }
            },
            metadata: {
                labels: {
                    name: "watchdog-pullrequest",
                    apptype: "monitoring"
                },
	        "namespace": "sam-system"
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-pullrequest"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-pullrequest"
        },
        name: "watchdog-pullrequest"
    }
} else "SKIP"
