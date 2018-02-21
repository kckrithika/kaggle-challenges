local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.kingdom == "frf" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-ipvs",
        },
        name: "slb-ipvs",
        namespace: "sam-system",
    },
    spec: {
        replicas: if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then 1 else 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-ipvs",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    {
                        name: "dev-volume",
                        hostPath: {
                            path: "/dev",
                         },
                    },
                    {
                        name: "lib-modules-volume",
                        hostPath: {
                            path: "/lib/modules",
                         },
                    },
                    {
                        name: "tmp-volume",
                        hostPath: {
                            path: "/tmp",
                         },
                    },
                    slbconfigs.usr_sbin_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                ]),
                containers: [
                    {
                        name: "slb-ipvs-installer",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-ipvs-installer",
                            "--modules=/sdn",
                            "--host=/host",
                            "--period=5s",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            configs.sfdchosts_arg,
                        ],
                        volumeMounts: configs.filter_empty([
                            {
                                name: "dev-volume",
                                mountPath: "/dev",
                            },
                            {
                                name: "lib-modules-volume",
                                mountPath: "/lib/modules",
                            },
                            {
                                name: "tmp-volume",
                                mountPath: "/host/tmp",
                            },
                            {
                                name: "lib-modules-volume",
                                mountPath: "/host/lib/modules",
                            },
                            slbconfigs.usr_sbin_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                    }
                    + (
                    if configs.estate == "prd-sdc" then {
                        securityContext: {
                            privileged: true,
                        },
                    } else {
                        securityContext: {
                            privileged: true,
                            capabilities: {
                                add: [
                                    "ALL",
                                ],
                            },
                        },
                    }
                    ),

                    {
                        name: "slb-ipvs-processor",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-ipvs-processor",
                            "--configDir=" + slbconfigs.configDir,
                            "--marker=" + slbconfigs.ipvsMarkerFile,
                            "--period=5s",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            "--maximumDeleteCount=20",
                            configs.sfdchosts_arg,
                        ]
                        + (
                            if configs.estate == "prd-sdc" then [
                                "--activateHealthChecker=true",
                            ] else []
                        ),
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            slbconfigs.usr_sbin_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                    },

                    {
                       name: "slb-ipvs-data",
                       image: slbimages.hypersdn,
                       command: [
                           "/sdn/slb-ipvs-data",
                           "--connPort=" + portconfigs.slb.ipvsDataConnPort,
                           "--log_dir=" + slbconfigs.logsDir,
                           configs.sfdchosts_arg,
                       ],
                       volumeMounts: configs.filter_empty([
                           slbconfigs.slb_volume_mount,
                           slbconfigs.logs_volume_mount,
                           slbconfigs.usr_sbin_volume_mount,
                           configs.sfdchosts_volume_mount,
                       ]),
                       securityContext: {
                           privileged: true,
                       },
                       ports: [
                             {
                                containerPort: portconfigs.slb.slbIpvsControlPort,
                             },
                       ],
                     }
                     + (
                        if configs.estate == "prd-sdc" then {
                            livenessProbe: {
                                httpGet: {
                                    path: "/",
                                    port: portconfigs.slb.ipvsDataConnPort,
                                },
                                initialDelaySeconds: 5,
                                periodSeconds: 3,
                            },
                        }
                        else {}
                      ),
                ],
                nodeSelector: {
                    "slb-service": "slb-ipvs",
                },
            },
        },
    },
} else "SKIP"
