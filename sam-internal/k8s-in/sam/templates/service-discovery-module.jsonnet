local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                containers: [
                    {
                        name: "service-discovery-module",
                        image: samimages.hypersam,
                        command:[
                            "/sam/service-discovery-module",
			                "-namespaceFilter=user-kdhabalia,cache-as-a-service-sp2,gater,user-prabhs",
			                "-zkIP="+configs.zookeeperip,
			                "-funnelEndpoint="+configs.funnelVIP,
                        ],
			    env: [
                          configs.kube_config_env
                        ],
                        volumeMounts: configs.cert_volume_mounts + [
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                       ],
                    }
                ],
                volumes: configs.cert_volumes + [
                    configs.cert_volume,
                    configs.kube_config_volume,
                ],
                nodeSelector: {
                } +
                if configs.kingdom == "prd" then {
                    master: "true"
                } else {
                     pool: configs.estate
                },

            },
            metadata: {
                labels: {
                    name: "service-discovery-module",
                    apptype: "control"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "service-discovery-module"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "service-discovery-module"
        },
        name: "service-discovery-module",
        namespace: "sam-system"
    }
} else "SKIP"
