local configs = import "config.jsonnet";
local wdconfig = import "wdconfig.jsonnet";

if configs.estate == "prd-sdc" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-watchdog",
                        image: configs.sdn_demo_watchdog,
                        command:[
                            "/sdn/watchdog",
                            "--role=PingValidator",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "--smtpServer="+configs.smtpServer,
                            "--recipient="+configs.sdn_demo_emailrec,
                            "--sender="+configs.sdn_demo_emailsender,
                            "--emailFrequency=60s",
                            "--alertThreshold=60s",
                            "--watchdogFrequency=60s"
                        ],
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                },
            },
            metadata: {
                labels: {
                    name: "sdn-watchdog",
                    apptype: "monitoring"
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-watchdog"
        },
        name: "sdn-watchdog"
    }
} else if configs.kingdom == "prd" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-watchdog",
                        image: configs.sdn_watchdog,
                        command:[
                            "/sdn/sdn-watchdog",
                            "--pingDelay=180s",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
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
                    name: "sdn-watchdog",
                    apptype: "monitoring"
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-watchdog"
        },
        name: "sdn-watchdog"
    }
} else "SKIP"
