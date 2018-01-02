local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-nginx-config",
        },
        name: "slb-nginx-config",
        namespace: "sam-system",
    },
    spec: {
        replicas: if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then 1 else 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-nginx-config",
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
                     slbconfigs.slb_config_volume,
                     slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        ports: [
                             {
                                name: "slb-nginx-port",
                                containerPort: portconfigs.slb.slbNginxControlPort,
                             },
                        ],
                        name: "slb-nginx-config",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-nginx-config",
                            "--configDir=" + slbconfigs.configDir,
                            "--target=" + slbconfigs.slbDir + "/nginx/config",
                            "--netInterfaceName=eth0",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                        ] + (if configs.estate == "prd-samtest" || configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-sam_storage" then [
                                                        "--configurePerPort=" + slbconfigs.configurePerPort,
                                                      ] else []) +
                        [
                            "--maxDeleteServiceCount=3",
                        ],
                        volumeMounts: configs.filter_empty([
                            {
                                name: "var-target-config-volume",
                                mountPath: slbconfigs.slbDir + "/nginx/config",
                            },
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                   },

                    {
                        name: "slb-nginx-proxy",
                        image: slbimages.slbnginx,
                        command: ["/runner.sh"],
                    }
                    + (
                        if configs.estate == "prd-sdc" then {
                            livenessProbe: {
                                httpGet: {
                                    path: "/",
                                    port: portconfigs.slb.slbNginxProxyLivenessProbePort,
                                },
                                initialDelaySeconds: 5,
                                periodSeconds: 3,
                            },
                            volumeMounts: configs.filter_empty([
                                {
                                    name: "var-target-config-volume",
                                    mountPath: "/etc/nginx/conf.d",
                                },
                                slbconfigs.logs_volume_mount,
                            ]),

                        }
                        else {
                            volumeMounts: configs.filter_empty([
                                {
                                    name: "var-target-config-volume",
                                    mountPath: "/etc/nginx/conf.d",
                                },
                            ]),
                        }
                       ),
                ],

                nodeSelector: {
                    "slb-service": "slb-nginx",
                },
            },
        },
    },
} else "SKIP"
