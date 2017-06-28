local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local utils = import "util_functions.jsonnet";

if !utils.is_public_cloud(configs.kingdom) then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-vault-agent",
                        image: sdnimages.hypersdn,
                        command:[
                            "/sdn/sdn-vault-agent",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "--keyfile=/data/certs/hostcert.key",
                            "--certfile=/data/certs/hostcert.crt",
                            "--cafile=/data/certs/ca.crt",
                            "--livenessProbePort="+portconfigs.sdn.sdn_vault_agent
                        ],
                        "livenessProbe": {
                            "httpGet": {
                               "path": "/liveness-probe",
                               "port": portconfigs.sdn.sdn_vault_agent
                            },
                            "initialDelaySeconds": 5,
                            "timeoutSeconds": 5,
                            "periodSeconds": 20
                        },
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
