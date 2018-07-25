local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + (if configs.estate != "prd-samtwo" then { dirSuffix:: "slb-nginx-config-b" } else {});
local portconfigs = import "portconfig.jsonnet";
local slbports = import "slbports.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-nginx-config-b" };
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile };

if slbconfigs.slbInKingdom then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-nginx-config-b",
        } + configs.ownerLabel.slb,
        name: "slb-nginx-config-b",
        namespace: "sam-system",
    },
    spec: {
        replicas: if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then 1 else (if slbconfigs.slbInProdKingdom || configs.estate == "prd-sam" || configs.estate == "prd-sdc" then 3 else 2),
        revisionHistoryLimit: 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-nginx-config-b",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": "{
                            \"certreqs\":[
                                {
                                    \"name\": \"cert1\",
                                    \"cert-type\":\"server\",
                                    \"kingdom\":\"prd\",
                                    \"role\": \"" + slbconfigs.samrole + "\",
                                    \"san\":[
                                        \"*.sam-system." + configs.estate + "." + configs.kingdom + ".slb.sfdc.net\",
                                        \"*.slb.sfdc.net\",
                                        \"*.soma.salesforce.com\",
                                        \"*.data.sfdc.net\"
                                    ]
                                },
                                {
                                    \"name\": \"cert2\",
                                    \"cert-type\":\"client\",
                                    \"kingdom\":\"prd\",
                                    \"role\": \"" + slbconfigs.samrole + "\"
                                }
                            ]
                         }",
                },
            },
            spec: {
                affinity: {
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
                },
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
                    {
                        emptyDir: {
                            medium: "Memory",
                        },
                        name: "cert1",
                    },
                    {
                        emptyDir: {
                            medium: "Memory",
                        },
                        name: "cert2",
                    },
                    {
                        emptyDir: {
                            medium: "Memory",
                        },
                        name: "tokens",
                    },
                    configs.maddog_cert_volume,
                    slbconfigs.sbin_volume,
                    configs.kube_config_volume,
                    configs.cert_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.cleanup_logs_volume,
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
                                                 "--maxDeleteServiceCount=20",
                                                 configs.sfdchosts_arg,
                                                 "--client.serverInterface=lo",
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
                                        {
                                            mountPath: "/cert1",
                                            name: "cert1",
                                        },
                                        {
                                            mountPath: "/cert2",
                                            name: "cert2",
                                        },
                                    ]),
                                },
                                slbshared.slbFileWatcher,
                                {
                                    args: [
                                        "/sam/madkub-client",
                                        "--madkub-endpoint",
                                        "https://$(MADKUBSERVER_SERVICE_HOST):32007",
                                        "--maddog-endpoint",
                                        configs.maddogEndpoint,
                                        "--maddog-server-ca",
                                        "/maddog-certs/ca/security-ca.pem",
                                        "--madkub-server-ca",
                                        "/maddog-certs/ca/cacerts.pem",
                                        "--cert-folders",
                                        "cert1:/cert1/",
                                        "--cert-folders",
                                        "cert2:/cert2/",
                                        "--token-folder",
                                        "/tokens/",
                                        "--requested-cert-type",
                                        "client",
                                        "--refresher",
                                        "--run-init-for-refresher-mode",
                                        "--ca-folder",
                                        "/maddog-certs/ca",
                                    ],
                                    env: [
                                        {
                                            name: "MADKUB_NODENAME",
                                            valueFrom: {
                                                fieldRef: {
                                                    fieldPath: "spec.nodeName",
                                                },
                                            },
                                        },
                                        {
                                            name: "MADKUB_NAME",
                                            valueFrom: {
                                                fieldRef: {
                                                    fieldPath: "metadata.name",
                                                },
                                            },
                                        },
                                        {
                                            name: "MADKUB_NAMESPACE",
                                            valueFrom: {
                                                fieldRef: {
                                                    fieldPath: "metadata.namespace",
                                                },
                                            },
                                        },
                                    ],
                                    image: samimages.madkub,
                                    name: "madkub-refresher",
                                    resources: {},
                                    volumeMounts: [
                                        {
                                            mountPath: "/cert1",
                                            name: "cert1",
                                        },
                                        {
                                            mountPath: "/cert2",
                                            name: "cert2",
                                        },
                                        {
                                            mountPath: "/tokens",
                                            name: "tokens",
                                        },
                                        {
                                            mountPath: "/maddog-certs/",
                                            name: "maddog-certs",
                                        },
                                    ],
                                },
                            ]
                            + (
                                if configs.estate != "prd-samtwo" then [
                                    {
                                        name: "slb-cert-checker",
                                        image: slbimages.hypersdn,
                                        command: [
                                            "/sdn/slb-cert-checker",
                                            "--metricsEndpoint=" + configs.funnelVIP,
                                            "--log_dir=" + slbconfigs.logsDir,
                                            configs.sfdchosts_arg,
                                        ],
                                        volumeMounts: configs.filter_empty([
                                            {
                                                name: "var-target-config-volume",
                                                mountPath: slbconfigs.slbDir + "/nginx/config",

                                            },
                                            {
                                                mountPath: "/cert1",
                                                name: "cert1",
                                            },
                                            {
                                                mountPath: "/cert2",
                                                name: "cert2",
                                            },
                                            slbconfigs.slb_volume_mount,
                                            slbconfigs.logs_volume_mount,
                                            configs.sfdchosts_volume_mount,
                                        ]),
                                    },
                                    slbshared.slbConfigProcessor(slbports.slb.slbConfigProcessorLivenessProbePort),
                                    slbshared.slbCleanupConfig,
                                    slbshared.slbNodeApi(slbports.slb.slbNodeApiPort),
                                    slbshared.slbRealSvrCfg(slbports.slb.slbNodeApiPort, true),
                                    slbshared.slbLogCleanup,
                                ] else []
                            ),
                initContainers: [
                    madkub.madkubInitContainer(),
                ],
            },
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
