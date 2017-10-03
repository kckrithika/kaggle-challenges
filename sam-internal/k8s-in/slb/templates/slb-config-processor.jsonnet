local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" then {
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
                "volumes": configs.filter_empty([
                    configs.maddog_cert_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.host_volume,
                    slbconfigs.logs_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                 ]),
                "containers": [
                    {
                        "name": "slb-config-processor",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-config-processor",
                            "--configDir="+slbconfigs.configDir,
                            "--period=1800s",
                            "--namespace="+slbconfigs.namespace,
                            "--podstatus=running",
                            "--subnet="+slbconfigs.subnet,
                            "--k8sapiserver=",
                            "--serviceList="+slbconfigs.serviceList,
                            "--useVipLabelToSelectSvcs="+slbconfigs.useVipLabelToSelectSvcs,
                            "--useProxyServicesList="+slbconfigs.useProxyServicesList,
                            "--metricsEndpoint="+configs.funnelVIP,
                            "--log_dir="+slbconfigs.logsDir,
                            "--sleepTime=100ms",
                        ],
                        "volumeMounts": configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.host_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                         ]),
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
