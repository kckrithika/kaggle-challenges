local configs = import "config.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-vip-watchdog" };
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-vip-watchdog" };

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || slbconfigs.slbInProdKingdom then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-vip-watchdog",
        },
        name: "slb-vip-watchdog",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
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
                                              "slb-ipvs-a",
                                              "slb-ipvs-b",
                                              "slb-nginx-config-b",
                                              "slb-nginx-config-a",
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
                                                  values: ["slb-ipvs", "slb-nginx-a", "slb-nginx-b"],
                                              },
                                          ] + (
                                              if configs.estate == "prd-sdc" then
                                                  [
                                                      {
                                                          key: "illumio",
                                                          operator: "NotIn",
                                                          values: ["a", "b"],
                                                      },
                                                  ] else []
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
                      ]),
                      containers: [
                          {
                              name: "slb-vip-watchdog",
                              image: slbimages.hypersdn,
                              command: [
                                  "/sdn/slb-vip-watchdog",
                                  "--log_dir=" + slbconfigs.logsDir,
                                  "--optOutNamespace=kne",
                                  "--hostnameOverride=$(NODE_NAME)",
                                  configs.sfdchosts_arg,
                                  "--metricsEndpoint=" + configs.funnelVIP,
                                  "--httpTimeout=5s",
                                  "--useLocalNodeApi=true",
                              ] + if configs.estate == "prd-sdc" then [
                                  "--vipLoop=1",
                                  "--monitorFrequency=10s",
                              ] else if configs.estate == "prd-sam" then [
                                  "--optOutServiceList=ops0-pkicontroller1-0-prd,git-test",
                                  "--vipLoop=1",
                                  "--monitorFrequency=10s",
                              ] else [
                                  "--vipLoop=10",
                                  "--monitorFrequency=60s",
                              ],
                              volumeMounts: configs.filter_empty([
                                  slbconfigs.slb_volume_mount,
                                  slbconfigs.logs_volume_mount,
                                  configs.sfdchosts_volume_mount,
                              ]),
                              env: [
                                  slbconfigs.node_name_env,
                              ],
                          },
                          slbshared.slbConfigProcessor,
                          slbshared.slbCleanupConfig,
                          slbshared.slbNodeApi,
                      ],
                  }
                  + (
                      if configs.estate == "prd-sam" || slbimages.phase == "3" || slbimages.phase == "4" then {
                          nodeSelector: {
                              pool: configs.kingdom + "-slb",
                          },
                      } else {
                          nodeSelector: {
                              pool: configs.estate,
                          },
                      }
                  ),
            metadata: {
                labels: {
                    name: "slb-vip-watchdog",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
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
