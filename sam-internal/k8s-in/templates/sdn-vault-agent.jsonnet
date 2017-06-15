local configs = import "config.jsonnet";
local wdconfig = import "wdconfig.jsonnet";

if configs.kingdom == "frf" || configs.kingdom == "prd" then {
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
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "--keyfile=/data/certs/hostcert.key",
                            "--certfile=/data/certs/hostcert.crt",
                            "--cafile=/data/certs/ca.crt"
                        ],
                        volumeMounts: [
                            {
                                name: "certs",
                                mountPath: "/data/certs",
                            }
                        ],
                    }
                ],
                volumes: [
                    {
                        name: "certs",
                        hostPath: {
                            path: "/data/certs",
                        }
                    },
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
