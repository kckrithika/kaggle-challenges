local configs = import "config.jsonnet";
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-vip-watchdog" };
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-vip-watchdog" };
local slbports = import "slbports.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || slbconfigs.slbInProdKingdom then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-vip-watchdog",
        } + slbconfigs.ownerLabel,
        name: "slb-vip-watchdog",
        namespace: "sam-system",
    },
    spec: {
        replicas: if configs.estate == "prd-sam" || configs.estate == "prd-sdc" then 2 else if slbconfigs.slbInProdKingdom then 3 else 1,
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
                                              ] + (if slbimages.hypersdn_build < 969 then [
                                                  "slb-nginx-config-b",
                                              ] else []) + [
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
                                                      values: ["slb-ipvs", "slb-nginx-a"] + (if slbimages.hypersdn_build < 969 then [
                                                         "slb-nginx-b",
                                                      ] else []),
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
                      ]),
                      containers: [
                          {
                              name: "slb-vip-watchdog",
                              image: slbimages.hypersdn,
                              command: [
                                  "/sdn/slb-vip-watchdog",
                                  "--log_dir=" + slbconfigs.logsDir,
                                  "--hostnameOverride=$(NODE_NAME)",
                                  configs.sfdchosts_arg,
                                  "--metricsEndpoint=" + configs.funnelVIP,
                                  "--httpTimeout=5s",
                                  "--vipLoop=1",
                                  "--monitorFrequency=10s",
                                  "--client.serverInterface=lo",
                                  "--healthPathCheck=" + (if slbimages.hypersdn_build >= 942 then "true" else "false"),
                                  "--metricsBatchTimeout=30s",
                              ] + (
                                  if slbimages.phaseNum <= 2 || configs.estate == "xrd-sam" then  # this block currently applies to phase 1, 2 and xrd-sam, pending rollout to more phases
                                      if std.objectHas(slbconfigs.perCluster.vipwdOptOutOptions, configs.estate) then
                                          slbconfigs.perCluster.vipwdOptOutOptions[configs.estate]
                                      else []
                                  else ["--optOutNamespace=kne"]  # keeps backward compatibility for phase 3/4
                              ),
                              volumeMounts: configs.filter_empty([
                                  slbconfigs.slb_volume_mount,
                                  slbconfigs.logs_volume_mount,
                                  configs.sfdchosts_volume_mount,
                              ]),
                              env: [
                                  slbconfigs.node_name_env,
                              ],
                          },
                          slbshared.slbConfigProcessor(slbports.slb.slbConfigProcessorLivenessProbePort),
                          slbshared.slbCleanupConfig,
                          slbshared.slbNodeApi(slbports.slb.slbNodeApiPort),
                          slbshared.slbLogCleanup,
                      ],
                  }
                  + (
                      if slbconfigs.isTestEstate then { nodeSelector: { pool: configs.estate } } else { nodeSelector: { pool: configs.kingdom + "-slb" } }
                  ),
            metadata: {
                labels: {
                    name: "slb-vip-watchdog",
                    apptype: "monitoring",
                } + slbconfigs.ownerLabel,
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
