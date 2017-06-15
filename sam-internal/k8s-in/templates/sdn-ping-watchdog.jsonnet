local configs = import "config.jsonnet";
local wdconfig = import "wdconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";

if configs.kingdom == "prd" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-ping-watchdog",
                        image: sdnimages.hypersdn,
                        command:[
                            "/sdn/sdn-ping-watchdog",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "--smtpServer="+configs.smtpServer,
                            "--sender="+configs.watchdog_emailsender,
                            "--recipient=sdn@salesforce.com",
                            "--emailFrequency=12h",
                            "--watchdogFrequency=180s",
                            "--alertThreshold=300s",
                            "--pingCount=1",
                            "--pingInterval=1s",
                            "--pingTimeout=5s"
                        ],
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                },
            },
            metadata: {
                labels: {
                    name: "sdn-ping-watchdog",
                    apptype: "monitoring"
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-ping-watchdog"
        },
        name: "sdn-ping-watchdog"
    }
} else "SKIP"
