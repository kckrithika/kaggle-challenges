local configs = import "config.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
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
                        command: std.prune([
                            "/sdn/sdn-vault-agent",
                            "--funnelEndpoint=" + configs.funnelVIP,
                            "--archiveSvcEndpoint=" + configs.tnrpArchiveEndpoint,
                            "--keyfile=" + configs.keyFile,
                            "--certfile=" + configs.certFile,
                            "--cafile=" + configs.caFile,
                            "--livenessProbePort=" + portconfigs.sdn.sdn_vault_agent,
                            sdnconfigs.logDirArg,
                            sdnconfigs.logToStdErrArg,
                        ]),
                        livenessProbe: {
                            httpGet: {
                               path: "/liveness-probe",
                               port: portconfigs.sdn.sdn_vault_agent,
                            },
                            initialDelaySeconds: 5,
                            timeoutSeconds: 5,
                            periodSeconds: 20,
                        },
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.maddog_cert_volume_mount,
                            {
                                name: "certs",
                                mountPath: "/data/certs",
                            },
                            sdnconfigs.conditional_sdn_logs_volume_mount,
                        ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    {
                        name: "certs",
                        hostPath: {
                            path: "/data/certs",
                        },
                    },
                    sdnconfigs.conditional_sdn_logs_volume,

                ]),
                nodeSelector: {
                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "sdn-vault-agent",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-vault-agent",
        },
        name: "sdn-vault-agent",
        namespace: "sam-system",
    },
} else "SKIP"
