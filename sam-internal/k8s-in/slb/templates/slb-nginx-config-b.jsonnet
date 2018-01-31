local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-nginx-config-b",
        },
        name: "slb-nginx-config-b",
        namespace: "sam-system",
    },
    spec: {
        replicas: if configs.estate == "prd-sdc" then 1 else 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-nginx-config-b",
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
                     configs.sfdchosts_volume,
                ]),
                containers: [
                    {
                        ports: [
                             {
                                name: "slb-nginx-port",
                                containerPort: portconfigs.slb.slbNginxControlPort,
                             },
                        ],
                        name: "slb-nginx-config-b",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-nginx-config",
                            "--configDir=" + slbconfigs.configDir,
                            "--target=" + slbconfigs.slbDir + "/nginx/config",
                            "--netInterfaceName=eth0",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            "--maxDeleteServiceCount=3",
                            configs.sfdchosts_arg,
                        ]
                        + (
                            if configs.estate == "prd-sdc" then [
                                "--httpsEnabled=true",
                            ] else []
                        ),
                        volumeMounts: configs.filter_empty([
                            {
                                name: "var-target-config-volume",
                                mountPath: slbconfigs.slbDir + "/nginx/config",
                            },
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                   },
                   ],

                nodeSelector: {
                    "slb-service": "slb-nginx-b",
                },
            },
        },
    },
} else "SKIP"
