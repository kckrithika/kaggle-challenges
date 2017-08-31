local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
    "apiVersion": "extensions/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "labels": {
            "name": "slb-nginx-config"
        },
        "name": "slb-nginx-config"
    },
    "spec": {
        replicas: 2,
        "template": {
            "metadata": {
                "labels": {
                    "name": "slb-nginx-config"
                }
            },
            "spec": {
                "hostNetwork": true,
                "volumes": [
                     slbconfigs.host_volume,
                     {
                        "name": "var-target-config-volume",
                        "hostPath": {
                            "path": "/var/slb/nginx/config"
                         }
                     },
                     slbconfigs.slb_config_volume,
                     slbconfigs.logs_volume,
                ],
                "containers": [
                    {
                        "name": "slb-nginx-config",
                        "image": slbimages.hypersdn,
                        "command":[
                            "/sdn/slb-nginx-config",
                            "--configDir="+slbconfigs.configDir,
                            "--target=/host/var/slb/nginx/config",
                            "--netInterfaceName=eth0",
                            "--metricsEndpoint="+configs.funnelVIP,
                            "--log_dir="+slbconfigs.logsDir
                        ],
                        "volumeMounts": [
                            slbconfigs.host_volume_mount,
                            {
                                "name": "var-target-config-volume",
                                "mountPath": "/host/var/slb/nginx/config"
                            },
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ],
                        "securityContext": {
                            "privileged": true
                        }
                   },

                    {
                        "name": "slb-nginx-proxy",
                        "image": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/mpopov/slb_nginx:v-071220171147",
                        "command": [ "/runner.sh" ],
                        "volumeMounts": [
                           {
                              "name": "var-target-config-volume",
                              "mountPath": "/etc/nginx/conf.d",
                           }
                        ]
                    } 
                ],

                "nodeSelector":{
                    "slb-service": "slb-nginx"
                }
            }
        }
    }
} else "SKIP"
