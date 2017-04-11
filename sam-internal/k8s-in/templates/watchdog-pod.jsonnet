local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-pod",
                        image: configs.watchdog,
                        command:[
                            "/sam/watchdog",
                            "-role=POD",
                            "-watchdogFrequency=60s",
                            "-alertThreshold=300s",
                            "-emailFrequency=24h",
                            "-timeout=2s",
                            "-funnelEndpoint="+configs.funnelVIP,
                            "-rcImtEndpoint="+configs.rcImtEndpoint,
                            "-smtpServer="+configs.smtpServer,
                            "-sender="+configs.watchdog_emailsender,
                            "-recipient="+configs.watchdog_emailrec,
                            "-tlsEnabled="+configs.tlsEnabled,
                            "-caFile="+configs.caFile,
                            "-keyFile="+configs.keyFile,
                            "-certFile="+configs.certFile,
                        ],
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                } +
                if configs.estate == "prd-samtest" then {
                    // In the case of samtest, we deploy only to master so we can assimilate the control-estate
                    // minions to consumer minions and extrapolate the required permissions for those nodes.
                    // When the testing of authorization is done, we can move back to normal (any node of the control-estate)
                    master: "true"
                } else {}
            },
            metadata: {
                labels: {
                    name: "watchdog-pod",
                    apptype: "monitoring"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-pod"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-pod"
        },
        name: "watchdog-pod"
    }
} else "SKIP"
