local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "slbports.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
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
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--deletePodPeriod=20m",
                            "--deleteIpvsStatePeriod=4h",
                            "--deleteConfigFilePeriod=50m",
                            "--deleteNginxTunnelIntfPeriod=2h",
                            "--deleteIpvsIntfPeriod=1.5h",
                            "--deleteCustomerPodPeriod=30m",
                            "--slbPodLabel=" + slbconfigs.podLabelList,
                            "--deletePodFlag=true",
                            configs.sfdchosts_arg,
                        ]
                        + (
                             if configs.estate == "prd-sdc" then [
                                  "--deleteIpvsStateFlag=true",
                                  "--deleteConfigFileFlag=true",
                                  "--deleteNginxTunnelIntfFlag=true",
                                  "--deleteIpvsIntfFlag=true",
                                  "--deleteCustomerPodFlag=true",
                             ] else [
                                  "--deleteIpvsStateFlag=false",
                                  "--deleteConfigFileFlag=false",
                                  "--deleteNginxTunnelIntfFlag=false",
                                  "--deleteIpvsIntfFlag=false",
                                  "--deleteCustomerPodFlag=false",
                             ]
                        ),
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
