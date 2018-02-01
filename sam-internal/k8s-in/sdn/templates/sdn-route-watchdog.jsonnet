local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local utils = import "util_functions.jsonnet";

if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxSurge: 1,
                maxUnavailable: 0,
            },
        },
        minReadySeconds: 180,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-route-watchdog",
                        image: sdnimages.hypersdn,
                        command: std.prune([
                            "/sdn/sdn-route-watchdog",
                            "--funnelEndpoint=" + configs.funnelVIP,
                            "--archiveSvcEndpoint=" + configs.tnrpArchiveEndpoint,
                            "--smtpServer=" + configs.smtpServer,
                            "--sender=" + sdnconfigs.sdn_watchdog_emailsender,
                            "--recipient=" + sdnconfigs.sdn_route_watchdog_emailrec,
                            "--emailFrequency=12h",
                            "--watchdogFrequency=180s",
                            "--alertThreshold=300s",
                            "--livenessProbePort=" + portconfigs.sdn.sdn_route_watchdog,
                            "--controlEstate=" + configs.estate,
                            "--rootPath=/etc/pki_service",
                            "--userName=kubernetes",
                            "--pkiClientServiceName=k8s-client",
                            "--momCollectorEndpoint=" + sdnconfigs.momVIP,
                            configs.sfdchosts_arg,
                            sdnconfigs.logDirArg,
                            sdnconfigs.logToStdErrArg,
                        ])
                        + (
                            if configs.estate == "prd-sdc" then [
                            "--sdncServiceName=sdn-control-svc",
                            "--sdncNamespace=sam-system",
                            ] else []
                        ),
                        env: [
                            configs.kube_config_env,
                        ],
                        livenessProbe: {
                            httpGet: {
                              path: "/liveness-probe",
                                port: portconfigs.sdn.sdn_route_watchdog,
                            },
                            initialDelaySeconds: 5,
                            timeoutSeconds: 5,
                            periodSeconds: 20,
                        },
                        volumeMounts: configs.filter_empty([
                            configs.sfdchosts_volume_mount,
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                            sdnconfigs.conditional_logs_volume_mount,
                        ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    sdnconfigs.conditional_logs_volume,
                ]),
                nodeSelector: {
                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "sdn-route-watchdog",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-route-watchdog",
        },
        name: "sdn-route-watchdog",
        namespace: "sam-system",
    },
} else "SKIP"
