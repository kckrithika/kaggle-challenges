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
                        name: "sdn-route-watchdog",
                        image: sdnimages.hypersdn,
                        command:[
                            "/sdn/sdn-route-watchdog",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "--momCollectorEndpoint="+configs.momCollectorEndpoint,
                            "--smtpServer="+configs.smtpServer,
                            "--sender="+configs.watchdog_emailsender,
                            "--recipient=sdn@salesforce.com",
                            "--emailFrequency=12h",
                            "--watchdogFrequency=180s",
                            "--alertThreshold=300s"
                        ],
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                },
            },
            metadata: {
                labels: {
                    name: "sdn-route-watchdog",
                    apptype: "monitoring"
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-route-watchdog"
        },
        name: "sdn-route-watchdog"
    }
} else "SKIP"
