local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local sdnconfig = import "sdnconfig.jsonnet";
local utils = import "util_functions.jsonnet";

if !utils.is_public_cloud(configs.kingdom) then {
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
                        command:[
                            "/sdn/sdn-route-watchdog",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "--momCollectorEndpoint="+configs.momCollectorEndpoint,
                            "--smtpServer="+configs.smtpServer,
                            "--sender="+sdnconfig.sdn_watchdog_emailsender,
                            "--recipient="+sdnconfig.sdn_watchdog_emailrec,
                            "--emailFrequency=12h",
                            "--watchdogFrequency=180s",
                            "--alertThreshold=300s",
                            "--livenessProbePort="+portconfigs.sdn.sdn_route_watchdog
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
                                "port": portconfigs.sdn.sdn_route_watchdog
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
                    name: "sdn-route-watchdog",
                    apptype: "monitoring"
                }
            }
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-route-watchdog"
        },
        name: "sdn-route-watchdog"
    }
} else "SKIP"
