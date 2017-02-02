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
                        name: "watchdog-node",
                        image: configs.watchdog_node,
                        command:[
                            "/sam/watchdog",
                            "-role=NODE",
                            "-watchdogFrequency=60s",
                            "-emailFrequency=24h",
                            "-timeout=2s",
                            "-funnelEndpoint="+configs.funnelVIP,
                            "-rcImtEndpoint="+configs.rcImtEndpoint,
                            "-smtpServer="+configs.smtpServer,
                            "-sender=prabh.singh@salesforce.com",
                            "-recipient=sam@salesforce.com",
                            "-cc=prabh.singh@salesforce.com,cdebains@salesforce.com,adhoot@salesforce.com,thargrove@salesforce.com,pporwal@salesforce.com,mayank.kumar@salesforce.com,prahlad.joshi@salesforce.com,xiao.zhou@salesforce.com,cbatra@salesforce.com"
                        ],
                       volumeMounts: [
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
                                path: "/etc/kubernetes"
                                },
                                name: "config"
                        }
                ],
                nodeSelector: {
                    pool: configs.estate
                }
            },
            metadata: {
                labels: {
                    name: "watchdog-node",
                    apptype: "monitoring"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "watchdog-node"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-node"
        },
        name: "watchdog-node"
    }
}
