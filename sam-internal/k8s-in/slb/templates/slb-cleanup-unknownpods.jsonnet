local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "slbports.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-samtwo" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || slbconfigs.slbInProdKingdom then configs.deploymentBase("slb") {
    metadata: {
         labels: {
                name: "slb-cleanup-unknownpods",
         } + configs.ownerLabel.slb,
         name: "slb-cleanup-unknownpods",
         namespace: "sam-system",
     },
    spec+: {
        replicas: 1,
        template: {
            spec: {
                securityContext: {
                     runAsUser: 0,
                     fsGroup: 0,
                 },
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                    configs.cert_volume,
                    configs.opsadhoc_volume,
                    configs.config_volume("slb-cleanup-unknownpods"),
                    configs.kube_config_volume,
                    {
                       hostPath: {
                          path: "/usr/bin/kubectl",
                       },
                       name: "kubectl",
                    },
                ]),
                containers: [
                    {
                        name: "slb-cleanup-unknownpods",
                        image: slbimages.hypersdn,
                         [if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
                        command: [
                            "/bin/bash",
                            "-xe",
                            "/config/slb-cleanup-unknownpods.sh",
                        ],
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.cert_volume_mount,
                            configs.opsadhoc_volume_mount,
                            configs.config_volume_mount,
                            configs.kube_config_volume_mount,
                            {
                                name: "kubectl",
                                mountPath: "/usr/bin/kubectl",
                            },
                        ]),
                        env: [
                            {
                               name: "NODE_NAME",
                               valueFrom: {
                                   fieldRef: {
                                       fieldPath: "spec.nodeName",
                                   },
                               },
                            },
                           configs.kube_config_env,
                        ],
                    },
                ],
                nodeSelector: {
                    master: "true",
                },
            },
            metadata: {
                labels: {
                    name: "slb-cleanup-unknownpods",
                    apptype: "monitoring",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
        },
    },
} else "SKIP"
