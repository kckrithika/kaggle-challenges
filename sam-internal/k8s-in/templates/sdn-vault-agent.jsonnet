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
                        name: "sdn-vault-agent",
                        image: configs.sdn_vault_agent,
                        command:[
                            "/sdn/sdn-vault-agent",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint
                        ],
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                },
            },
            metadata: {
                labels: {
                    name: "sdn-vault-agent",
                    apptype: "monitoring"
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-vault-agent"
        },
        name: "sdn-vault-agent"
    }
} else "SKIP"
