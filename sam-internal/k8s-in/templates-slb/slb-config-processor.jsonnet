local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
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
                    configs.cert_volume,
                    configs.kube_config_volume,
                 ],
                "containers": [
                    {
                        "name": "slb-config-processor",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-config-processor",
                            "--configDir="+slbconfigs.configDir,
                            "--period=15s",
                            "--namespace=sam-system",
                            "--podstatus=running",
                            "--subnet="+slbconfigs.subnet,
                            "--k8sapiserver="+configs.k8sapiserver,
                            "--serviceList="+slbconfigs.serviceList,
                            "--useVipLabelToSelectSvcs="+slbconfigs.useVipLabelToSelectSvcs,
                            "--useProxyServicesList="+slbconfigs.useProxyServicesList,
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
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                         ],
                         env: [
                            configs.kube_config_env,
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
