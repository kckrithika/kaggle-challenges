local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.kingdom == "prd" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-nginx-proxy",
        },
        name: "slb-nginx-proxy",
        namespace: "sam-system",
    },
    spec: {
        replicas: if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then 1 else 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-nginx-proxy",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                     {
                        name: "var-target-config-volume",
                        hostPath: {
                            path: slbconfigs.slbDockerDir + "/nginx/config",
                         },
                     },
                     slbconfigs.logs_volume,
                ]),
                containers: [
                {
                    name: "slb-nginx-proxy",
                    image: slbimages.slbnginx,
                    command: ["/runner.sh"],
                livenessProbe: {
                    httpGet: {
                        path: "/",
                        port: portconfigs.slb.slbNginxProxyLivenessProbePort,
                    },
                    initialDelaySeconds: 15,
                    periodSeconds: 10,
                },
                volumeMounts: configs.filter_empty([
                {
                    name: "var-target-config-volume",
                    mountPath: "/etc/nginx/conf.d",
                },
                slbconfigs.logs_volume_mount,
                ]),
},
                ],

                nodeSelector: {
                    "slb-service": "slb-nginx",
                },
            },
        },
    },
} else "SKIP"
