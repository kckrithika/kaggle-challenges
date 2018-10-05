local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-portal" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-portal" };
local portconfigs = import "portconfig.jsonnet";
local slbports = import "slbports.jsonnet";
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-portal" };
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: "slb-nginx-config-b" };

local certDirs = ["cert3"];

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-samtwo" || configs.estate == "prd-samdev" || configs.estate == "prd-sam_storage" || slbconfigs.slbInProdKingdom then configs.deploymentBase("slb") {
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
            } + (if slbflights.roleBasedSecrets then {
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.manifestJsonEx(madkub.madkubSlbCertsAnnotation(certDirs), " "),
                },
            } else {}),
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
                      ] + (if slbflights.roleBasedSecrets then madkub.madkubSlbCertVolumes(certDirs) + madkub.madkubSlbMadkubVolumes() else [])),
                      containers: [
                          {
                              name: "slb-portal",
                              image: slbimages.hypersdn,
                              [if configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
                              command: [
                                           "/sdn/slb-portal",
                                           "--hostname=$(NODE_NAME)",
                                           "--templatePath=" + slbconfigs.slbPortalTemplatePath,
                                           "--port=" + portconfigs.slb.slbPortalServicePort,
                                           "--client.serverInterface=lo",
                                       ] + (if slbflights.roleBasedSecrets then [
                                           "--keyfile=/cert3/client/keys/client-key.pem",
                                           "--certfile=/cert3/client/certificates/client.pem",
                                           "--log_dir=/host/data/slb/logs/slb-portal",
                                           "--cafile=/cert3/ca/cabundle.pem",
                                       ] else [
                                           "--keyfile=/etc/pki_service/platform/platform-client/keys/platform-client-key.pem",
                                           "--certfile=/etc/pki_service/platform/platform-client/certificates/platform-client.pem",
                                           "--log_dir=/host/data/slb/logs/slb-portal",
                                           "--cafile=/etc/pki_service/ca/cabundle.pem",
<<<<<<< HEAD
                                       ])
                                       + (if slbconfigs.isTestEstate then [
=======
                                       ] + (if slbconfigs.isTestEstate && configs.estate != "prd-samtwo" then [
>>>>>>> added sln-portal and canary services to sam-two + make setting identical to prod
                                                "--slbEstate=" + configs.estate,
                                            ] else [])
                                       + slbflights.getNodeApiClientSocketSettings(slbconfigs.configDir),
                              volumeMounts: configs.filter_empty(
                                  [
                                      slbconfigs.slb_volume_mount,
                                      configs.maddog_cert_volume_mount,
                                      configs.cert_volume_mount,
                                  ] + (if slbflights.roleBasedSecrets then madkub.madkubSlbCertVolumeMounts(certDirs) else [])
                              ),
                              livenessProbe: {
                                  httpGet: {
                                      path: "/",
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
                          },
                          slbshared.slbConfigProcessor(slbports.slb.slbConfigProcessorLivenessProbePort),
                          slbshared.slbCleanupConfig,
                          slbshared.slbNodeApi(slbports.slb.slbNodeApiPort, true),
                          slbshared.slbLogCleanup,
                      ] + (if slbflights.roleBasedSecrets then [madkub.madkubRefreshContainer(certDirs)] else []) + slbflights.getManifestWatcherIfEnabled(),
                      nodeSelector: {
                          "slb-dns-register": "true",
                      },
                  } + (if slbflights.roleBasedSecrets then {
                     initContainers: [
                         madkub.madkubInitContainer(certDirs),
                     ],
                  } else {})
                  + slbflights.getDnsPolicy()
                  + (
                      if configs.estate == "prd-sdc" then {
                          affinity: {
                              podAntiAffinity: {
                                  requiredDuringSchedulingIgnoredDuringExecution: [{
                                      labelSelector: {
                                          matchExpressions: [{
                                              key: "name",
                                              operator: "In",
                                              values: [
                                                  "slb-ipvs",
                                                  "slb-ipvs-a",
                                                  "slb-ipvs-b",
                                              ],
                                          }],
                                      },
                                      topologyKey: "kubernetes.io/hostname",
                                  }],
                              },
                              nodeAffinity: {
                                  requiredDuringSchedulingIgnoredDuringExecution: {
                                      nodeSelectorTerms: [
                                          {
                                              matchExpressions: [
                                                  {
                                                      key: "slb-service",
                                                      operator: "NotIn",
                                                      values: ["slb-ipvs"],
                                                  },
                                                  {
                                                      key: "slb-dns-register",
                                                      operator: "In",
                                                      values: ["true"],
                                                  },
                                              ],
                                          },
                                      ],
                                  },
                              },
                          },
                      } else {}
                  ),
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
