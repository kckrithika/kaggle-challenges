local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "slbports.jsonnet";
local slbflights = import "slbflights.jsonnet";

if slbconfigs.isSlbEstate then configs.deploymentBase("slb") {
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
                volumes: std.prune([
                    configs.maddog_cert_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                    configs.cert_volume,
                    configs.opsadhoc_volume,
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
                        image: slbimages.hyperslb,
                        command: [
                            "/bin/bash",
                            "/sdn/slb-cleanup-stuckpods.sh",
                        ],
                        volumeMounts: std.prune([
                            configs.maddog_cert_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.cert_volume_mount,
                            configs.opsadhoc_volume_mount,
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
            } + slbconfigs.getDnsPolicy()
            + {
              // Run on hostNetwork to avoid potential docker networking issues preventing this pod from talking to the kube api server.
              hostNetwork: true,
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
