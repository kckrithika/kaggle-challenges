local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local sdnconfig = import "sdnconfig.jsonnet";
local utils = import "util_functions.jsonnet";

if configs.kingdom == "prd" then {
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
                        command: [
                            "/sdn/sdn-route-watchdog",
                            "--funnelEndpoint=" + configs.funnelVIP,
                            "--archiveSvcEndpoint=" + configs.tnrpArchiveEndpoint,
                            "--smtpServer=" + configs.smtpServer,
                            "--sender=" + sdnconfig.sdn_watchdog_emailsender,
                            "--recipient=" + sdnconfig.sdn_watchdog_emailrec,
                            "--emailFrequency=12h",
                            "--watchdogFrequency=180s",
                            "--alertThreshold=300s",
                            "--livenessProbePort=" + portconfigs.sdn.sdn_route_watchdog,
                            "--controlEstate=" + configs.estate,

                        ]
                        + (
                            if configs.estate == "prd-sdc" then [
                            "--sdncServiceName=sdn-control-svc",
                            "--sdncNamespace=sam-system",
                            "--rootPath=/etc/pki_service",
                            "--userName=kubernetes",
                            "--pkiClientServiceName=k8s-client",
                            "--momCollectorEndpoint=https://ops0-momapi1-0-prd.data.sfdc.net/api/v1/network/device?key=host-bgp-routes",
                            ] else [
                            "--momCollectorEndpoint=" + configs.momCollectorEndpoint,
                            ]
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
                        ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
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
} else if !utils.is_public_cloud(configs.kingdom) then {
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
                        command: [
                            "/sdn/sdn-route-watchdog",
                            "--funnelEndpoint=" + configs.funnelVIP,
                            "--archiveSvcEndpoint=" + configs.tnrpArchiveEndpoint,
                            "--momCollectorEndpoint=" + configs.momCollectorEndpoint,
                            "--smtpServer=" + configs.smtpServer,
                            "--sender=" + sdnconfig.sdn_watchdog_emailsender,
                            "--recipient=" + sdnconfig.sdn_watchdog_emailrec,
                            "--emailFrequency=12h",
                            "--watchdogFrequency=180s",
                            "--alertThreshold=300s",
                            "--livenessProbePort=" + portconfigs.sdn.sdn_route_watchdog,
                        ] + (if configs.estate == "frf-sam" then ["--controlEstate=" + configs.estate] else []),
                        env: [
                            {
                                name: "KUBECONFIG",
                                value: "/config/kubeconfig",
                            },
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
                            {
                                mountPath: "/data/certs",
                                name: "certs",
                            },
                            {
                                mountPath: "/config",
                                name: "config",
                            },
                        ]),
                    },
                ],
                volumes: configs.filter_empty([
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    {
                        hostPath: {
                            path: "/data/certs",
                        },
                        name: "certs",
                    },
                    {
                        hostPath: {
                            path: "/etc/kubernetes",
                        },
                        name: "config",
                    },
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
