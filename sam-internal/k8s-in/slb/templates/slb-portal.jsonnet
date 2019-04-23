local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-portal" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-portal" };
local portconfigs = import "portconfig.jsonnet";
local slbports = import "slbports.jsonnet";
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-portal" };
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: "slb-nginx-config-b" };

local certDirs = ["cert3"];

if slbconfigs.isSlbEstate && configs.estate != "prd-samtest" then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-portal",
        } + configs.ownerLabel.slb,
        name: "slb-portal",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-portal",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.manifestJsonEx(madkub.madkubSlbCertsAnnotation(certDirs), " "),
                },
            },
            spec: {
                      volumes: configs.filter_empty([
                          slbconfigs.slb_volume,
                          configs.maddog_cert_volume,
                          slbconfigs.slb_config_volume,
                          slbconfigs.logs_volume,
                          configs.sfdchosts_volume,
                          configs.cert_volume,
                          configs.kube_config_volume,
                          slbconfigs.cleanup_logs_volume,
                          slbconfigs.proxyconfig_volume,
                      ] + madkub.madkubSlbCertVolumes(certDirs) + madkub.madkubSlbMadkubVolumes()),
                      containers: [
                          {
                              name: "slb-portal",
                              image: slbimages.hyperslb,
                              command: [
                                           "/sdn/slb-portal",
                                           "--hostname=$(NODE_NAME)",
                                           "--templatePath=" + slbconfigs.slbPortalTemplatePath,
                                           "--port=" + portconfigs.slb.slbPortalServicePort,
                                           "--client.serverInterface=lo",
                                           "--keyfile=/cert3/client/keys/client-key.pem",
                                           "--certfile=/cert3/client/certificates/client.pem",
                                           "--log_dir=/host/data/slb/logs/slb-portal",
                                           "--cafile=/cert3/ca/cabundle.pem",
                                           configs.sfdchosts_arg,
                                       ]
                                       + (if slbconfigs.isTestEstate then [
                                                "--slbEstate=" + configs.estate,
                                            ] else [])
                                       + slbconfigs.getNodeApiClientSocketSettings(),
                              volumeMounts: configs.filter_empty(
                                  [
                                      slbconfigs.slb_volume_mount,
                                      configs.maddog_cert_volume_mount,
                                      configs.cert_volume_mount,
                                      configs.sfdchosts_volume_mount,
                                  ] + madkub.madkubSlbCertVolumeMounts(certDirs)
                              ),
                              livenessProbe: {
                                  httpGet: {
                                    # Portal's root endpoint (`/`) queries DNS for every page load. VIP watchdog (reachability on the target port and VIP availability) and kubelet
                                    # (liveness probe) both hit this endpoint every 3 seconds, causing undue stress on DNS lookups. Change the liveness probe endpoint to something
                                    # less dependent on external systems. Unfortunately, VIP watchdog's reachability probe can't be similarly configured.
                                    # https://gus.lightning.force.com/a07B0000006QrWiIAK (when implemented) should help with portal's page load times.
                                    # https://gus.lightning.force.com/a07B0000005jkagIAA (when implemented) should allow us to reduce VIP watchdog's load on the main portal page.
                                      path: "/webfiles/",
                                      port: portconfigs.slb.slbPortalServicePort,
                                  },
                                  initialDelaySeconds: 30,
                                  periodSeconds: 3,
                                  timeoutSeconds: 30,
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
                              ],
                          } + configs.ipAddressResourceRequest,
                          slbshared.slbConfigProcessor(slbports.slb.slbConfigProcessorLivenessProbePort, includeSlbPortalOverride=slbflights.slbPortalEndpointOverride),
                          slbshared.slbCleanupConfig,
                          slbshared.slbNodeApi(slbports.slb.slbNodeApiPort, true),
                          slbshared.slbLogCleanup,
                          madkub.madkubRefreshContainer(certDirs),
                          slbshared.slbManifestWatcher(includeSlbPortalOverride=slbflights.slbPortalEndpointOverride),
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
} else "SKIP"
