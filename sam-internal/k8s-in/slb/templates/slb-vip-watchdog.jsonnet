local configs = import "config.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-vip-watchdog" };
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-vip-watchdog" };
local slbports = import "slbports.jsonnet";
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-vip-watchdog" };
local slbdnsregisterconfig = import "slb-dns-register.jsonnet";

local certDirs = ["cert3"];
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: "slb-nginx-config-b" };

if slbconfigs.isSlbEstate then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-vip-watchdog",
        } + configs.ownerLabel.slb,
        name: "slb-vip-watchdog",
        namespace: "sam-system",
    },
    spec+: {
        replicas: if configs.estate == "prd-sdc" then 2 else if (slbconfigs.isProdEstate && configs.estate != "prd-samtwo") then 3 else 1,
        template: {
            spec: {
                      affinity: {
                          podAntiAffinity: {
                              requiredDuringSchedulingIgnoredDuringExecution: [{
                                  labelSelector: {
                                      matchExpressions: [
                                          {
                                              key: "name",
                                              operator: "In",
                                              values: [
                                                  "slb-ipvs",
                                                  "slb-ipvs-a",
                                                  "slb-ipvs-b",
                                                  "slb-nginx-config-a",
                                                  "slb-vip-watchdog",
                                              ],
                                          },
                                      ],
                                  },
                                  topologyKey: "kubernetes.io/hostname",
                              }],
                          },
                          nodeAffinity: {
                              requiredDuringSchedulingIgnoredDuringExecution: {
                                  nodeSelectorTerms: [
                                      {
                                          matchExpressions: [
                                          ] + (
                                              if configs.estate == "prd-sdc" then
                                                  [
                                                      {
                                                          key: "illumio",
                                                          operator: "NotIn",
                                                          values: ["a", "b"],
                                                      },
                                                      {
                                                          key: "slb-service",
                                                          operator: "NotIn",
                                                          values: ["slb-ipvs", "slb-ipvs-a", "slb-nginx-a"],
                                                      },
                                                  ] else if configs.estate == "prd-sam" then [
                                                  {
                                                      key: "slb-service",
                                                      operator: "NotIn",
                                                      values: ["slb-ipvs", "slb-ipvs-a", "slb-nginx-a"],
                                                  },
                                              ] else [
                                                  {
                                                      key: "slb-service",
                                                      operator: "NotIn",
                                                      values: ["slb-ipvs", "slb-nginx-a"],
                                                  },
                                              ]
                                          ),
                                      },
                                  ],
                              },
                          },
                      },
                      volumes: configs.filter_empty([
                          slbconfigs.slb_volume,
                          slbconfigs.logs_volume,
                          configs.sfdchosts_volume,
                          configs.maddog_cert_volume,
                          slbconfigs.slb_config_volume,
                          configs.cert_volume,
                          configs.kube_config_volume,
                          slbconfigs.cleanup_logs_volume,
                          slbconfigs.proxyconfig_volume,
                      ] + (if slbimages.phase == "1" then
                            madkub.madkubSlbCertVolumes(certDirs) + madkub.madkubSlbMadkubVolumes() + [slbconfigs.reservedips_volume]
                           else [])),
                      containers: [
                          {
                              name: "slb-vip-watchdog",
                              image: slbimages.hyperslb,
                              command: [
                                           "/sdn/slb-vip-watchdog",
                                           "--log_dir=" + slbconfigs.logsDir,
                                           "--hostnameOverride=$(NODE_NAME)",
                                           configs.sfdchosts_arg,
                                           "--metricsEndpoint=" + configs.funnelVIP,
                                           "--httpTimeout=3s",
                                           "--vipLoop=1",
                                           "--monitorFrequency=10s",
                                           "--client.serverInterface=lo",
                                           "--metricsBatchTimeout=30s",
                                       ] + (if slbflights.alertOnlyOnProxyErrorCode then [
                                           "--featureFlagAlertOnlyOnProxyErrorCode=true",
                                       ] else [])
                                       + slbconfigs.vipwdConfigOptions
                                       + slbconfigs.getNodeApiClientSocketSettings(),
                              volumeMounts: configs.filter_empty([
                                  slbconfigs.slb_volume_mount,
                                  slbconfigs.logs_volume_mount,
                                  configs.sfdchosts_volume_mount,
                              ] +
                              (if slbimages.phase == "1" then
                                madkub.madkubSlbCertVolumeMounts(certDirs)
                                + [slbconfigs.reservedips_volume_mount]
                              else [])),
                              env: [
                                  slbconfigs.node_name_env,
                                  slbconfigs.function_namespace_env,
                                  slbconfigs.function_instance_name_env,
                              ],
                          } + configs.ipAddressResourceRequest,
                          slbshared.slbConfigProcessor(slbports.slb.slbConfigProcessorLivenessProbePort),
                          slbshared.slbCleanupConfig,
                          slbshared.slbNodeApi(slbports.slb.slbNodeApiPort, true),
                          slbshared.slbLogCleanup,
                          slbshared.slbManifestWatcher(),
                      ] + (if slbimages.phase == "1" then [madkub.madkubRefreshContainer(certDirs)] else []),
                      dnsPolicy: "Default",
                  } + slbconfigs.getGracePeriod()
                  + slbconfigs.slbEstateNodeSelector
                  + (if slbimages.phase == "1" then {
                            initContainers: [
                                madkub.madkubInitContainer(certDirs),
                            ],
                        }
                    else {}),
            metadata: {
                labels: {
                    name: "slb-vip-watchdog",
                    apptype: "monitoring",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            }
            +
            (
if slbimages.phase == "1" then
            {
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.manifestJsonEx(madkub.madkubSlbCertsAnnotation(certDirs), " "),
                },
            }
            else
                {}
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
