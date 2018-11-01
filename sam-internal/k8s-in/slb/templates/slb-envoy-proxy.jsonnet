local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: slbconfigs.envoyProxyName };
local portconfigs = import "portconfig.jsonnet";
local slbports = import "slbports.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: slbconfigs.envoyProxyName };
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: slbconfigs.envoyProxyName };
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: slbconfigs.envoyProxyName };

local certDirs = ["cert1", "cert2"];

local sherpaContainer = {
    env: [
        // See https://git.soma.salesforce.com/servicelibs/sherpa-envoy/blob/a075369d86202b459fed04534f8eb913df50f912/launcher/config.go#L170-L174
        // for required environment variables.
        {
            name: "FUNCTION_NAMESPACE",
            valueFrom: {
                fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.namespace",
                },
            },
        },
        {
            name: "SETTINGS_SUPERPOD",
            value: "None",
        },
        {
            name: "SETTINGS_PATH",
            value: "-.-." + configs.kingdom + ".-." + slbconfigs.envoyProxyName,
        },
    ],
    image: "ops0-artifactrepo2-0-prd.data.sfdc.net/sfci/servicelibs/sherpa-envoy:e6ae1aef47d40fa3d4a184f8a446cb4bb8c90b71",
    imagePullPolicy: "Always",
    name: "sherpa",
    ports: [
        {
            containerPort: 7014,
            name: "http1",
        },
        {
            containerPort: 7442,
            name: "http1-tls",
        },
        {
            containerPort: 15373,
            name: "sherpa-adm",
        },
    ],
    securityContext: {
        runAsNonRoot: true,
        runAsUser: 7447,
    },
    volumeMounts: [
        {
            mountPath: "/client-certs",
            name: "cert2",
        },
        {
            mountPath: "/server-certs",
            name: "cert1",
        },
    ],
};

if slbconfigs.isSlbEstate && slbflights.envoyProxyEnabled then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: slbconfigs.envoyProxyName,
        } + configs.ownerLabel.slb,
        name: slbconfigs.envoyProxyName,
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        revisionHistoryLimit: 2,
        template: {
            metadata: {
                labels: {
                    name: slbconfigs.envoyProxyName,
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.manifestJsonEx(madkub.madkubSlbCertsAnnotation(certDirs), " "),
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
                                      "slb-ipvs",
                                      slbconfigs.envoyProxyName,
                                  ],
                              }],
                            },
                            topologyKey: "kubernetes.io/hostname",
                      }],
                    },
                },
                securityContext: {
                    fsGroup: 7447,
                },
                volumes: std.prune([
                    {
                        name: "slb-envoy-nginx-configuration",
                        configMap: {
                            name: "slb-envoy-nginx-configuration",
                        },
                    },
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                    configs.sfdchosts_volume,
                    configs.maddog_cert_volume,
                    configs.kube_config_volume,
                    configs.cert_volume,
                    slbconfigs.slb_config_volume,
                    slbconfigs.cleanup_logs_volume,
                    slbconfigs.sbin_volume,
                ] + madkub.madkubSlbCertVolumes(certDirs)
                + madkub.madkubSlbMadkubVolumes()),
                containers: [
                    {
                        name: slbconfigs.envoyProxyName,
                        image: slbimages.slbnginx,
                        command: ["nginx", "-g", "daemon off;"],
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
                                name: "slb-envoy-nginx-configuration",
                                mountPath: "/etc/nginx/conf.d",
                            },
                            slbconfigs.nginx_logs_volume_mount,
                            slbconfigs.slb_volume_mount,
                        ] + madkub.madkubSlbCertVolumeMounts(certDirs)),
                    },
                    sherpaContainer,
                    madkub.madkubRefreshContainer(certDirs),
                    slbshared.slbConfigProcessor(slbports.slb.slbConfigProcessorLivenessProbePort),
                    slbshared.slbCleanupConfig,
                    slbshared.slbNodeApi(slbports.slb.slbNodeApiPort, false),
                    slbshared.slbRealSvrCfg(slbports.slb.slbNodeApiPort, true),
                    slbshared.slbLogCleanup,
                ],
                initContainers: [
                    madkub.madkubInitContainer(certDirs),
                ],
                dnsPolicy: "Default",
                nodeSelector: { pool: slbconfigs.slbEstate },
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
