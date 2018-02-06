local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local utils = import "util_functions.jsonnet";
if utils.is_flowsnake_cluster(configs.estate) then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-secret-agent",
                        image: sdnimages.hypersdn,
                        command: std.prune([
                           "/sdn/sdn-secret-agent",
                           "--funnelEndpoint=" + configs.funnelVIP,
                           "--logtostderr=true",
                           "--disableSecurityCheck=true",
                           "--tnrpEndpoint=" + configs.tnrpArchiveEndpoint,
                           "--observeMode=" + false,
                           "--delay=300s",
                           "--keyfile=" + configs.keyFile,
                           "--certfile=" + configs.certFile,
                           "--cafile=" + configs.caFile,
                           "--livenessProbePort=" + portconfigs.sdn.sdn_secret_agent,
                           configs.sfdchosts_arg,
                           sdnconfigs.logDirArg,
                           sdnconfigs.logToStdErrArg,
                         ]),
                         volumeMounts: configs.filter_empty([
                           configs.sfdchosts_volume_mount,
                           configs.maddog_cert_volume_mount,
                           configs.cert_volume_mount,
                           configs.kube_config_volume_mount,
                           sdnconfigs.conditional_sdn_logs_volume_mount,
                         ]),
                         env: [
                           configs.kube_config_env,
                         ],
                         livenessProbe: {
                            httpGet: {
                                path: "/liveness-probe",
                                port: portconfigs.sdn.sdn_secret_agent,
                            },
                            initialDelaySeconds: 10,
                            timeoutSeconds: 5,
                            periodSeconds: 30,
                        },
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    sdnconfigs.conditional_sdn_logs_volume,
                ]),
            },
            metadata: {
                labels: {
                    name: "sdn-secret-agent",
                    apptype: "control",
                },
               namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-secret-agent",
        },
        name: "sdn-secret-agent",
    },
} else "SKIP"
