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
                        name: "sdn-ping-watchdog",
                        image: sdnimages.hypersdn,
                        command:[
                            "/sdn/sdn-ping-watchdog",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "--smtpServer="+configs.smtpServer,
                            "--sender="+sdnconfig.sdn_watchdog_emailsender,
                            "--recipient="+sdnconfig.sdn_watchdog_emailrec,
                            "--emailFrequency=12h",
                            "--watchdogFrequency=180s",
                            "--alertThreshold=300s",
                            "--pingCount=1",
                            "--pingInterval=1s",
                            "--pingTimeout=5s",
                            "--livenessProbePort="+portconfigs.sdn.sdn_ping_watchdog
                        ] + (if configs.kingdom == "prd" then ["--controlEstate="+configs.estate] else ["--controlEndpoint="+configs.estate]),
                        "env": [
                            configs.kube_config_env
                        ],
                        "livenessProbe": {
                            "httpGet": {
                                "path": "/liveness-probe",
                                "port": portconfigs.sdn.sdn_ping_watchdog
                            },
                            "initialDelaySeconds": 5,
                            "timeoutSeconds": 5,
                            "periodSeconds": 20
                        },
                        "volumeMounts": configs.cert_volume_mounts + [
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.config_volume_mount,
                        ]
                    }
                ],
                "volumes": configs.cert_volumes + [
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("watchdog"),
                ],
                nodeSelector: {
                    pool: configs.estate
                },
            },
            metadata: {
                labels: {
                    name: "sdn-ping-watchdog",
                    apptype: "monitoring"
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-ping-watchdog"
        },
        name: "sdn-ping-watchdog"
    }
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
                        name: "sdn-ping-watchdog",
                        image: sdnimages.hypersdn,
                        command:[
                            "/sdn/sdn-ping-watchdog",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "--smtpServer="+configs.smtpServer,
                            "--sender="+sdnconfig.sdn_watchdog_emailsender,
                            "--recipient="+sdnconfig.sdn_watchdog_emailrec,
                            "--emailFrequency=12h",
                            "--watchdogFrequency=180s",
                            "--alertThreshold=300s",
                            "--pingCount=1",
                            "--pingInterval=1s",
                            "--pingTimeout=5s",
                            "--livenessProbePort="+portconfigs.sdn.sdn_ping_watchdog
                        ],
                        "env": [
                            {
                                "name": "KUBECONFIG",
                                "value": "/config/kubeconfig"
                            }
                        ],
                        "livenessProbe": {
                            "httpGet": {
                                "path": "/liveness-probe",
                                "port": portconfigs.sdn.sdn_ping_watchdog
                            },
                            "initialDelaySeconds": 5,
                            "timeoutSeconds": 5,
                            "periodSeconds": 20
                        },
                        "volumeMounts": configs.cert_volume_mounts + [
                            {
                                "mountPath": "/data/certs",
                                "name": "certs"
                            },
                            {
                                "mountPath": "/config",
                                "name": "config"
                            }
                        ]
                    }
                ],
                "volumes": configs.cert_volumes + [
                    {
                        "hostPath": {
                            "path": "/data/certs"
                        },
                        "name": "certs"
                    },
                    {
                        "hostPath": {
                            "path": "/etc/kubernetes"
                        },
                        "name": "config"
                    }
                ],
                nodeSelector: {
                    pool: configs.estate
                },
            },
            metadata: {
                labels: {
                    name: "sdn-ping-watchdog",
                    apptype: "monitoring"
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-ping-watchdog"
        },
        name: "sdn-ping-watchdog"
    }
} else "SKIP"
