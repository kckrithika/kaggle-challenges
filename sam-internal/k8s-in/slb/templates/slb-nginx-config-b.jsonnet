local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-nginx-config-b" };
local portconfigs = import "portconfig.jsonnet";
local slbports = import "slbports.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-nginx-config-b" };
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: "slb-nginx-config-b" };
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-nginx-config-b" };

local certDirs = ["cert1", "cert2"];

if slbconfigs.isSlbEstate then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-nginx-config-b",
        } + configs.ownerLabel.slb,
        name: "slb-nginx-config-b",
        namespace: "sam-system",
    },
    spec+: {
        replicas: if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then 1 else (if slbconfigs.slbInProdKingdom || configs.estate == "prd-sam" || configs.estate == "prd-sdc" then 3 else 2),
        revisionHistoryLimit: 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-nginx-config-b",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.manifestJsonEx(madkub.madkubSlbCertsAnnotation(certDirs), " "),
                },
            },
            spec: {
                affinity:
                (if slbflights.nginxPodFloat then {
                    podAntiAffinity: {
                        requiredDuringSchedulingIgnoredDuringExecution: [{
                            labelSelector: {
                              matchExpressions: [{
                                  key: "name",
                                  operator: "In",
                                  values: [
                                      "slb-ipvs",
                                      "slb-nginx-config-b",
                                  ],
                              }],
                            },
                            topologyKey: "kubernetes.io/hostname",
                      }],
                    },
                } else {
                    podAntiAffinity: {
                        requiredDuringSchedulingIgnoredDuringExecution: [{
                            labelSelector: {
                                matchExpressions: [{
                                    key: "name",
                                    operator: "In",
                                    values: [
                                        "slb-nginx-config-b",
                                    ],
                                }],
                            },
                            topologyKey: "kubernetes.io/hostname",
                        }],
                    },
                    nodeAffinity: {
                        requiredDuringSchedulingIgnoredDuringExecution: {
                            nodeSelectorTerms: [{
                                matchExpressions: [{
                                    key: "slb-service",
                                    operator: "In",
                                    values: ["slb-nginx-b"],
                                }],
                            }],
                        },
                    },
                }),
                volumes: configs.filter_empty([
                    {
                        name: "var-target-config-volume",
                        hostPath: {
                            path: slbconfigs.slbDockerDir + "/nginx/config",
                        },
                    },
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                ] + madkub.madkubSlbCertVolumes(certDirs) + madkub.madkubSlbMadkubVolumes() + [
                    configs.maddog_cert_volume,
                    slbconfigs.sbin_volume,
                    configs.kube_config_volume,
                    configs.cert_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.cleanup_logs_volume,
                    {
                        emptyDir: {
                            medium: "Memory",
                        },
                        name: "customer-certs",
                    },
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
                                     [if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
                                    command: [
                                        "/sdn/slb-nginx-config",
                                        "--target=" + slbconfigs.slbDir + "/nginx/config",
                                        "--netInterfaceName=eth0",
                                        "--metricsEndpoint=" + configs.funnelVIP,
                                        "--log_dir=" + slbconfigs.logsDir,
                                        "--maxDeleteServiceCount=" + slbconfigs.perCluster.maxDeleteCount[configs.estate],
                                    ]
                                    + [
                                        configs.sfdchosts_arg,
                                        "--client.serverInterface=lo",
                                        "--hostnameOverride=$(NODE_NAME)",
                                    ]
                                      + (if slbimages.phaseNum == 1 then [
                                            "--blueGreenFeature=true",
                                        ] else [])
                                      + (if slbimages.phaseNum <= 2 then [
                                            "--httpconfig.trustedProxies=" + slbconfigs.perCluster.trustedProxies[configs.estate],
                                        ] else [])
                                      + slbconfigs.getNodeApiClientSocketSettings()
                                      + [
                                            "--enableSimpleDiff=true",
                                            "--newConfigGenerator=true",
                                            "--control.nginxReloadSentinel=" + slbconfigs.slbDir + "/nginx/config/nginx.marker",
                                      ]
                                      + (if slbimages.hypersdn_build >= 1279 then [
                                            "--httpconfig.custCertsDir=" + slbconfigs.customerCertsPath,
                                        ] else [
                                            "--custCertsDir=" + slbconfigs.customerCertsPath,
                                        ])
                                      + [
                                            "--checkDuplicateVips=true",
                                      ],
                                    volumeMounts: configs.filter_empty([
                                        {
                                            name: "var-target-config-volume",
                                            mountPath: slbconfigs.slbDir + "/nginx/config",
                                        },
                                        slbconfigs.slb_volume_mount,
                                        slbconfigs.logs_volume_mount,
                                        configs.sfdchosts_volume_mount,
                                    ]),
                                    securityContext: {
                                        privileged: true,
                                    },
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
                                {
                                    name: "slb-nginx-proxy-b",
                                    image: slbimages.slbnginx,
                                    command: ["/runner.sh"],
                                    livenessProbe: {
                                        httpGet: {
                                            path: "/",
                                            port: portconfigs.slb.slbNginxProxyLivenessProbePort,
                                        },
                                        initialDelaySeconds: 15,
                                        periodSeconds: 10,
                                    },
                                    volumeMounts: configs.filter_empty([
                                        {
                                            name: "var-target-config-volume",
                                            mountPath: "/etc/nginx/conf.d",
                                        },
                                        slbconfigs.nginx_logs_volume_mount,
                                    ] + madkub.madkubSlbCertVolumeMounts(certDirs) +
                                    [
                                        {
                                            mountPath: slbconfigs.customerCertsPath,
                                            name: "customer-certs",
                                        },
                                    ]),
                                },
                                {
                                 name: "slb-nginx-data",
                                 image: slbimages.hypersdn,
                                 command: [
                                     "/sdn/slb-nginx-data",
                                     "--target=" + slbconfigs.slbDir + "/nginx/config",
                                     "--connPort=" + slbports.slb.nginxDataConnPort,
                                 ],
                                 volumeMounts: configs.filter_empty([
                                     slbconfigs.slb_volume_mount,
                                     slbconfigs.logs_volume_mount,
                                     configs.sfdchosts_volume_mount,
                                 ]),
                                 livenessProbe: {
                                     httpGet: {
                                         path: "/",
                                         port: slbports.slb.nginxDataConnPort,
                                     },
                                     initialDelaySeconds: 5,
                                     periodSeconds: 3,
                                 },
                                },
                                slbshared.slbFileWatcher,
                                madkub.madkubRefreshContainer(certDirs),
                                {
                                        name: "slb-cert-checker",
                                        image: slbimages.hypersdn,
                                        command: [
                                            "/sdn/slb-cert-checker",
                                            "--metricsEndpoint=" + configs.funnelVIP,
                                            "--hostnameOverride=$(NODE_NAME)",
                                            "--log_dir=" + slbconfigs.logsDir,
                                            configs.sfdchosts_arg,
                                        ],
                                        volumeMounts: configs.filter_empty([
                                            {
                                                name: "var-target-config-volume",
                                                mountPath: slbconfigs.slbDir + "/nginx/config",

                                            },
                                        ] + madkub.madkubSlbCertVolumeMounts(certDirs) + [
                                            slbconfigs.slb_volume_mount,
                                            slbconfigs.logs_volume_mount,
                                            configs.sfdchosts_volume_mount,
                                            {
                                                mountPath: slbconfigs.customerCertsPath,
                                                name: "customer-certs",
                                            },
                                        ]),
                                        env: [
                                            slbconfigs.node_name_env,
                                        ],
                                },
                                slbshared.slbConfigProcessor(slbports.slb.slbConfigProcessorLivenessProbePort),
                                slbshared.slbCleanupConfig,
                                slbshared.slbNodeApi(slbports.slb.slbNodeApiPort, true),
                                slbshared.slbRealSvrCfg(slbports.slb.slbNodeApiPort, true),
                                slbshared.slbLogCleanup,
                                slbshared.slbManifestWatcher(),
                                {
                                    name: "slb-cert-deployer",
                                    image: slbimages.hypersdn,
                                    command: [
                                        "/sdn/slb-cert-deployer",
                                        "--metricsEndpoint=" + configs.funnelVIP,
                                        "--hostnameOverride=$(NODE_NAME)",
                                        "--log_dir=" + slbconfigs.logsDir,
                                        "--custCertsDir=" + slbconfigs.customerCertsPath,
                                        configs.sfdchosts_arg,
                                    ] + slbconfigs.getNodeApiClientSocketSettings(),
                                    volumeMounts: configs.filter_empty([
                                        {
                                            name: "var-target-config-volume",
                                            mountPath: slbconfigs.slbDir + "/nginx/config",

                                        },
                                    ] + madkub.madkubSlbCertVolumeMounts(certDirs) + [
                                        {
                                            mountPath: slbconfigs.customerCertsPath,
                                            name: "customer-certs",
                                        },
                                        slbconfigs.slb_volume_mount,
                                        slbconfigs.logs_volume_mount,
                                        configs.sfdchosts_volume_mount,
                                    ]),
                                    env: [
                                        slbconfigs.node_name_env,
                                    ],
                                },
                            ],
                initContainers: [
                    madkub.madkubInitContainer(certDirs),
                ],
                dnsPolicy: "Default",
            }
            + (
            if slbflights.nginxPodFloat then {
                nodeSelector: { pool: slbconfigs.slbEstate },
            } else {}
            ),
        },
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 0,
            },
        },
        minReadySeconds: 60,
    },
} else "SKIP"
