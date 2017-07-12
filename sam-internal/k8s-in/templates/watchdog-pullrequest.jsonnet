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
                        ]
                        + samwdconfig.shared_args,
                        volumeMounts: [
                          {
                             "mountPath": "/var/token",
                             "name": "token",
                             "readOnly" : true
                          }
                       ],
                    }
                ],
                volumes: [
                    {
                        secret: {
                            secretName: "git-token"
                          },
                        name: "token"
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                }
            },
            metadata: {
                labels: {
                    name: "watchdog-pullrequest",
                    apptype: "monitoring"
                }
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
