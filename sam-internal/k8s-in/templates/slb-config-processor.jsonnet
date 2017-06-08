local configs = import "config.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
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
                            "--period=5s",
                            "--namespace=default",
                            "--subnet=10.251.129.224/27",
                            "--k8sApiServer="+configs.apiserver,
                            "--serviceList=slb-alpha,slb-bravo,slb-charlie,slb-delta,slb-echo",
                            "--vipList=10.251.129.230:9090,10.251.129.231:9090,10.251.129.232:9090,10.251.129.233:9090,10.251.129.234:9090",
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
