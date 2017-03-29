local configs = import "config.jsonnet";

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
