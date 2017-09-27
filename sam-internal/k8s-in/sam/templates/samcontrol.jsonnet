local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
{

    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sam-controller",
                        image: samimages.hypersam,
                        command:[
                           "/sam/sam-controller",
                           "--dockerregistry="+configs.registry,
                           "--funnelEndpoint="+configs.funnelVIP,
                           "--v=3",
                           "--logtostderr=true",
                           "--config=/config/samcontrol.json",
                        ] + (if configs.estate == "prd-sam" || configs.estate == "prd-samtest" then [
                        # Kept here because of the use of the envvar. Keep in sync with the config.
                        "-maddogMadkubEndpoint=" + "https://$(MADKUBSERVER_SERVICE_HOST):32007",
                        ] else []),
                       volumeMounts: configs.cert_volume_mounts + [
                          configs.cert_volume_mount,
                          configs.kube_config_volume_mount,
                          configs.config_volume_mount,
                       ],
                       env: [
                          configs.kube_config_env,
                       ]
                    }
                ],
                volumes: configs.cert_volumes + [
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.config_volume("samcontrol"),
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
                    name: "samcontrol",
                    apptype: "control"
                }
            }
        },
        selector: {
            matchLabels: {
                name: "samcontrol"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "samcontrol"
        },
        name: "samcontrol"
    }
}
