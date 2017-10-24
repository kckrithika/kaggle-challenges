local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" then {
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
        replicas: 2,
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
                    (if configs.estate == "prd-sdc" then
                    {
                        name: "tmp-volume",
                        hostPath: {
                            path: "/tmp",
                         },
                    }
                    else slbconfigs.host_volume),
                    (if configs.estate == "prd-sdc" then slbconfigs.usr_sbin_volume else {}),
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-ipvs-installer",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-ipvs-installer",
                            "--modules=/sdn",
                            "--host=/host",
                            "--marker=" + slbconfigs.slbDir + "/ipvs.marker",
                            "--period=5s",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                        ],
                        volumeMounts: configs.filter_empty([
                            {
                                name: "dev-volume",
                                mountPath: "/dev",
                            },
                            {
                                name: "lib-modules-volume",
                                mountPath: (if configs.estate == "prd-sdc" then "/host/lib/modules" else "/lib/modules"),
                            },
                            (if configs.estate == "prd-sdc" then
                            {
                                name: "tmp-volume",
                                mountPath: "/host/tmp",
                            }
                            else slbconfigs.host_volume_mount),
                            (if configs.estate == "prd-sdc" then slbconfigs.usr_sbin_volume_mount else {}),
                            slbconfigs.logs_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                            capabilities: {
                                add: [
                                    "ALL",
                                ],
                            },
                        },
                    },

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
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            (if configs.estate == "prd-sdc" then slbconfigs.usr_sbin_volume_mount else {}),
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
                       ],
                       volumeMounts: configs.filter_empty([
                           slbconfigs.slb_volume_mount,
                           slbconfigs.logs_volume_mount,
                           (if configs.estate == "prd-sdc" then slbconfigs.usr_sbin_volume_mount else {}),
                       ]),
                       securityContext: {
                           privileged: true,
                       },
                    },
                ],
                nodeSelector: {
                    "slb-service": "slb-ipvs",
                },
            },
        },
    },
} else "SKIP"
