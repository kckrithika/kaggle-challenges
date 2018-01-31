local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "slbports.jsonnet";

if configs.estate == "prd-sdc" then {
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
                hostNetwork: true,
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
                            "--deletePodPeriod=1h",
                            "--deletePodFlag=true",
                            "--deleteIpvsStatePeriod=4h",
                            "--deleteIpvsStateFlag=true",
                            "--deleteConfigFilePeriod=8h",
                            "--deleteConfigFileFlag=true",
                            "--deleteNginxTunnelIntfPeriod=12h",
                            "--deleteNginxTunnelIntfFlag=true",
                            "--deleteIpvsIntfPeriod=15h",
                            "--deleteIpvsIntfFlag=true",
                            "--deleteCustomerPodFlag=true",
                            "--deleteCustomerPodPeriod=1.5h",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--slbPodLabel=" + slbconfigs.podLabelList,
                            "--k8sapiserver=",
                            "--namespace=sam-system",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--hostnameoverride=$(NODE_NAME)",
                            "--port=" + portconfigs.slb.baboonEndPointPort,
                            configs.sfdchosts_arg,
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
