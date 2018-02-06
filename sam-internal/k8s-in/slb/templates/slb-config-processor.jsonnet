local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "slbports.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        labels: {
            name: "slb-config-processor",
        },
        name: "slb-config-processor",
        namespace: "sam-system",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    name: "slb-config-processor",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                affinity: {
                   nodeAffinity: {
                                                                 requiredDuringSchedulingIgnoredDuringExecution: {
                                                                   nodeSelectorTerms: [
                                                                     {
                                                                        matchExpressions: [
                                                                          {
                                                                             key: "slb.sfdc.net/role",
                                                                             operator: "DoesNotExist",
                                                                          },
                                                                        ],
                                                                     },
                                                                   ],
                                                                 },
                                                               },
                                                             },


                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.sfdchosts_volume,
                 ]),
                containers: [
                    {
                        name: "slb-config-processor",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-config-processor",
                            "--configDir=" + slbconfigs.configDir,
                            "--period=1800s",
                            "--namespace=" + slbconfigs.namespace,
                            "--podstatus=running",
                            "--subnet=" + slbconfigs.subnet,
                            "--k8sapiserver=",
                            "--serviceList=" + slbconfigs.serviceList,
                            "--useVipLabelToSelectSvcs=" + slbconfigs.useVipLabelToSelectSvcs,
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            "--sleepTime=100ms",
                            "--processKnEConfigs=" + slbconfigs.processKnEConfigs,
                            "--kneConfigDir=" + slbconfigs.kneConfigDir,
                            "--kneDomainName=" + slbconfigs.kneDomainName,
                            "--livenessProbePort=" + portconfigs.slb.slbConfigProcessorLivenessProbePort,
                            "--shouldRemoveConfig=true",
                            configs.sfdchosts_arg,
                            "--proxySelectorLabelValue=slb-nginx-config-b",
                        ] + if configs.estate == "prd-sdc" then [
                            "--servicesNotToLbOverride=" + slbconfigs.servicesNotToLbOverride,
                        ] else [],
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.sfdchosts_volume_mount,
                         ]),
                         env: [
                            configs.kube_config_env,
                        ],
                        securityContext: {
                            privileged: true,
                        },
                        livenessProbe: {
                          httpGet: {
                             path: "/liveness-probe",
                             port: portconfigs.slb.slbConfigProcessorLivenessProbePort,
                          },
                          initialDelaySeconds: 600,
                          timeoutSeconds: 5,
                          periodSeconds: 30,
                        },
                    },
                    {
                        name: "slb-cleanup-config-processor",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-cleanup",
                            "--period=1800s",
                            "--logsMaxAge=1h",
                            "--filesDirToCleanup=" + slbconfigs.configDir,
                            "--shouldSkipServiceRecords=true",
                            "--shouldNotDeleteAllFiles=true",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--skipFilesWithSuffix=slb.block",
                        ] + if configs.estate == "prd-sam" then [
                            "--maxDeleteFileCount=15",
                        ] else [
                            "--maxDeleteFileCount=3",
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                    },
                ],
            },
        },
    },
} else "SKIP"
