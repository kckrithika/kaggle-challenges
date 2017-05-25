local configs = import "config.jsonnet";

if configs.estate == "prd-sdc" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "DaemonSet",
    "metadata": {
        "labels": {
            "name": "slb-config-processor"
        },
        "name": "slb-config-processor"
    },
    "spec": {
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-config-processor",
                    "apptype": "control",
                    "daemonset": "true"
                }
            },
            "spec": {
                "hostNetwork": true,
                "volumes": [
                    {
                        "name": "var-slb-volume",
                        "hostPath": {
                            "path": "/var/slb"
                         }
                    },
                    {
                        "name": "var-config-volume",
                        "hostPath": {
                        "path": "/var/slb/config"
                        }
                    },
                    {
                        "name": "host-volume",
                        "hostPath": {
                            "path": "/"
                         }
                    },
                    {
                        "name": "certs",
                        "hostPath": {
                            "path": "/data/certs",
                        }
                     },
                     {
                        "name": "config",
                        "hostPath": {
                            "path": "/etc/kubernetes",
                         }
                    }
                 ],
                "containers": [
                    {
                        "name": "slb-config-processor",
                        "image": configs.slb_config_processor,
                        "command":[
                            "/sdn/slb-config-processor",
                            "--configDir=/host/var/slb/config",
                            "--services=/host/var/slb/services",
                            "--servers=/host/var/slb/servers",
                            "--available=/host/var/slb/available",
                            "--period=5s",
                            "--namespace=default",
                            "--k8sapiserver="+configs.apiserver,
                            "--serviceList=slb-test-svc",
                            "--vipList=10.251.129.235:9090",
                            "--metricsEndpoint="+configs.funnelVIP
                        ],
                        "volumeMounts": [
                            {
                                "name": "var-slb-volume",
                                "mountPath": "/host/var/slb"
                            },
                            {
                                "name": "var-config-volume",
                                "mountPath": "/host/var/slb/config"
                            },
                            {
                                "name": "host-volume",
                                "mountPath": "/host"
                            },
                            {
                                "name": "certs",
                                "mountPath": "/data/certs"
                            },
                            {
                               "name": "config",
                               "mountPath": "/config"
                            }
                         ],
                         env: [
                            {
                                "name": "KUBECONFIG",
                                "value": configs.configPath
                            }
                        ],
                        "securityContext": {
                            "privileged": true
                        }
                    }
                ]
            }
        }
    }
} else "SKIP"
