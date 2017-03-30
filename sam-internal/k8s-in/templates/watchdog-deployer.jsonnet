{
local configs = import "config.jsonnet",

    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "watchdog-deployer",
                        image: configs.watchdog,
                        command:[
                            "/sam/watchdog",
                            "-role=DEPLOYER",
                            "-watchdogFrequency=120s",
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
                            "-deployer-imageName="+configs.watchdog,
                            "-deployer-funnelEndpoint="+configs.funnelVIP,
                            "-deployer-rcImtEndpoint="+configs.rcImtEndpoint,
                            "-deployer-smtpServer="+configs.smtpServer,
                            "-deployer-sender="+configs.watchdog_emailsender,
                            "-deployer-recipient="+configs.watchdog_emailrec,
                        ],
                       volumeMounts: [
                          {
                             "mountPath": "/data/certs",
                             "name": "certs"
                          },
                          {
                             "mountPath": "/config",
                             "name": "config"
                          }
                       ],
                       env: [
                          {
                             "name": "KUBECONFIG",
                             "value": configs.configPath
                          }
                       ]
                    }
                ],
                volumes: [
                    {
                        hostPath: {
                                path: "/data/certs"
                                },
                                name: "certs"
                        },
                        {
                        hostPath: {
                                path: "/etc/kubernetes"
                                },
                                name: "config"
                        }
                ],
                nodeSelector: {
                    pool: configs.estate
                } +
                if configs.estate == "prd-samtest" then {
                    // In the case of samtest, we deploy only to master so we can assimilate the control-estate
                    // minions to consumer minions and extrapolate the required permissions for those nodes.
                    // When the testing of authorization is done, we can move back to normal (any node of the control-estate)
                    master: true
                } else {}
            },
            metadata: {
                labels: {
                    name: "watchdog-deployer",
                    apptype: "monitoring"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-deployer"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-deployer"
        },
        name: "watchdog-deployer"
    }
}
