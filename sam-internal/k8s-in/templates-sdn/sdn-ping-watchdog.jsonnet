local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnimages = import "sdnimages.jsonnet";
local wdconfig = import "wdconfig.jsonnet";
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
                        name: "sdn-ping-watchdog",
                        image: sdnimages.hypersdn,
                        command:[
                            "/sdn/sdn-ping-watchdog",
                            "--funnelEndpoint="+configs.funnelVIP,
                            "--archiveSvcEndpoint="+configs.tnrpArchiveEndpoint,
                            "--smtpServer="+configs.smtpServer,
                            "--sender="+configs.sdn_watchdog_emailsender,
                            "--recipient="+configs.sdn_watchdog_emailrec,
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
                        "volumeMounts": [
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
                "volumes": [
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
