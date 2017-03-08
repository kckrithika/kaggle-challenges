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
                        name: "sdc-watchdog",
                        image: configs.sdc_watchdog,
                        command:[
                            "/sdc/sdc-watchdog",
                            "--pingDelay=180s",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--tnrpEndpoint="+configs.tnrpArchiveEndpoint,
                            "--pingCount=1",
                            "--pingInterval=1s",
                            "--pingTimeout=5s"
                        ],
                    }
                ],
            },
            metadata: {
                labels: {
                    name: "sdc-watchdog",
                    apptype: "monitoring"
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdc-watchdog"
        },
        name: "sdc-watchdog"
    }
} else "SKIP"
