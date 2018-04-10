local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "slbports.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam"then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
            labels: {
                name: "slb-baboon",
            },
            name: "slb-baboon",
            namespace: "sam-system",
     },
    spec: {
        replicas: 1,
        template: {
            spec: {
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.logs_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    {
                       hostPath: {
                          path: "/usr/bin/kubectl",
                       },
                       name: "kubectl",
                    },
                    configs.sfdchosts_volume,
                ]),
                containers: [
                    {
                        name: "slb-baboon",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-baboon",
                            "--k8sapiserver=",
                            "--namespace=sam-system",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--hostnameoverride=$(NODE_NAME)",
                            "--port=" + portconfigs.slb.baboonEndPointPort,
                            configs.sfdchosts_arg,
                            "--metricsEndpoint=" + configs.funnelVIP,

                            "--deletePodPeriod=20m",
                            "--deleteIpvsStatePeriod=4h",

                            "--deleteConfigFilePeriod=50m",
                            "--deleteConfigFileFlag=true",
                            "--deleteNginxTunnelIntfPeriod=2h",
                            "--deleteNginxTunnelIntfFlag=true",
                            "--deleteIpvsIntfPeriod=1.5h",
                            "--deleteIpvsIntfFlag=true",
                            "--deleteCustomerPodFlag=true",
                            "--deleteCustomerPodPeriod=30m",

                            "--slbPodLabel=" + slbconfigs.podLabelList,
                            "--deleteIpvsStateFlag=true",
                            "--deletePodFlag=true",
                        ],
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                            {
                                name: "kubectl",
                                mountPath: "/usr/bin/kubectl",
                            },
                            configs.sfdchosts_volume_mount,
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
                    pool: configs.estate,
                    master: "true",
                },
            },
            metadata: {
                labels: {
                    name: "slb-baboon",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
    },
} else "SKIP"
