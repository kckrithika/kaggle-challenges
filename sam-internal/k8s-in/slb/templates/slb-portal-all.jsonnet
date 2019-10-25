local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbports = import "slbports.jsonnet";
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: "slb-nginx-config-b" };

local deployments = [
    {
        local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-portal-" + kingdomName },
        local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-portal-" + kingdomName },
        local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-portal-" + kingdomName },
        local certDirs = ["cert3"],
        local vipLocation = kingdomName + "-sam." + kingdomName,
        local pseudoApiServerLink = "http://pseudo-kubeapi.csc-sam.prd-sam.prd.slb.sfdc.net:40001/" + kingdomName + '-sam',
        local deploymentName = "slb-portal-" + kingdomName,

        local healthProbes = {
            livenessProbe: {
                httpGet: {
                    path: "/healthz",
                    port: portconfigs.slb.slbPortalServicePort,
                },
                # Attainment data loader takes up to 12 minutes to query argus for SLA attainment.
                # TODO: Parallelize portal metric queries to speed this up.
                initialDelaySeconds: 900,
                periodSeconds: 10,
                timeoutSeconds: 3,
            },
        },

        deployment: configs.deploymentBase("slb") {
            metadata: {
                labels: {
                    name: deploymentName,
                } + configs.ownerLabel.slb,
                name: deploymentName,
                namespace: "sam-system",
            },
            spec+: {
                replicas: 1,
                template: {
                    metadata: {
                        labels: {
                            name: deploymentName,
                        } + configs.ownerLabel.slb,
                        namespace: "sam-system",
                        annotations: {
                            "madkub.sam.sfdc.net/allcerts": std.manifestJsonEx(madkub.madkubSlbCertsAnnotation(certDirs), " "),
                        },
                    },
                    spec: {
                            volumes: std.prune([
                                slbconfigs.slb_volume,
                                configs.maddog_cert_volume,
                                slbconfigs.slb_config_volume,
                                slbconfigs.logs_volume,
                                configs.sfdchosts_volume,
                                configs.cert_volume,
                                configs.kube_config_volume,
                                slbconfigs.cleanup_logs_volume,
                                slbconfigs.proxyconfig_volume,
                                configs.config_volume("slb-portal-links"),
                            ] + madkub.madkubSlbCertVolumes(certDirs) + madkub.madkubSlbMadkubVolumes()),
                            containers: [
                                {
                                    name: deploymentName,
                                    image: slbimages.hyperslb,
                                    command: [
                                                "/sdn/slb-portal",
                                                "--hostname=$(NODE_NAME)",
                                                "--templatePath=" + slbconfigs.slbPortalTemplatePath,
                                                "--port=" + portconfigs.slb.slbPortalServicePort,
                                                "--client.serverInterface=lo",
                                                "--keyfile=/cert3/client/keys/client-key.pem",
                                                "--certfile=/cert3/client/certificates/client.pem",
                                                "--log_dir=/host/data/slb/logs/" + deploymentName,
                                                "--cafile=/cert3/ca/cabundle.pem",
                                                "--aggregatedPortal=true",
                                                configs.sfdchosts_arg,
                                                "--vipdnsoptions.viplocation=" + vipLocation,
                                            ]
                                            + (if slbimages.phaseNum <= 2 then [
                                                "--metricsEndpoint=" + configs.funnelVIP,
                                            ] else [])
                                            + (if slbconfigs.isTestEstate then [
                                                        "--slbEstate=" + configs.estate,
                                                    ] else [])
                                            + slbconfigs.getNodeApiClientSocketSettings(),
                                    volumeMounts: std.prune(
                                        [
                                            slbconfigs.slb_volume_mount,
                                            configs.maddog_cert_volume_mount,
                                            configs.cert_volume_mount,
                                            configs.sfdchosts_volume_mount,
                                            configs.config_volume_mount,
                                        ] + madkub.madkubSlbCertVolumeMounts(certDirs)
                                    ),
                                    env: [
                                        slbconfigs.node_name_env,
                                    ],
                                } + configs.ipAddressResourceRequest + healthProbes,
                                slbshared.slbConfigProcessor(
                                    slbports.slb.slbConfigProcessorLivenessProbePort,
                                    includeSlbPortalOverride=slbconfigs.isSlbAggregatedPortalEstate,
                                    vipLocationName=vipLocation,
                                    pseudoApiServer=pseudoApiServerLink
                                ),
                                slbshared.slbCleanupConfig,
                                slbshared.slbNodeApi(slbports.slb.slbNodeApiPort, true),
                                slbshared.slbLogCleanup,
                                madkub.madkubRefreshContainer(certDirs),
                                slbshared.slbManifestWatcher(includeSlbPortalOverride=slbconfigs.isSlbAggregatedPortalEstate, vipLocationName=vipLocation),
                            ],
                            nodeSelector: { pool: slbconfigs.slbEstate },
                            initContainers: [
                                madkub.madkubInitContainer(certDirs),
                            ],
                        }
                        + slbconfigs.getGracePeriod()
                        + slbconfigs.getDnsPolicy()
                        + {
                                affinity: {
                                    podAntiAffinity: {
                                        requiredDuringSchedulingIgnoredDuringExecution: [{
                                            labelSelector: {
                                                matchExpressions: [{
                                                    key: "name",
                                                    operator: "In",
                                                    values: [
                                                        "slb-ipvs",
                                                    ],
                                                }],
                                            },
                                            topologyKey: "kubernetes.io/hostname",
                                        }],
                                    },
                                },
                        },
                },
                strategy: {
                    type: "RollingUpdate",
                    rollingUpdate: {
                        maxUnavailable: 1,
                        maxSurge: 1,
                    },
                },
                minReadySeconds: 30,
            },
        },
    }
for kingdomName in slbconfigs.prodKingdoms
];

local slbflights = import "slbflights.jsonnet";

if slbconfigs.isSlbEstate && slbconfigs.isSlbAggregatedPortalEstate then {
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: [
        deployment.deployment
for deployment in deployments
    ],
} else "SKIP"
