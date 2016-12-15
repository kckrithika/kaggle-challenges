local configs = import "config.jsonnet";
if configs.estate == "prd-sdc" then {
    kind: "Deployment",
    spec: {
        replicas: 3,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdc-peering-agent",
                        image: configs.registry + "/sdc-peering-agent:latest"
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                }
            },
            metadata: {
                labels: {
                    name: "sdc-peering-agent",
                    apptype: "control"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "sdc-peering-agent"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdccontrol"
        },
        name: "sdccontrol"
    }
} else "SKIP"
