local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-portal" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-portal" };
local portconfigs = import "portconfig.jsonnet";
local slbports = import "slbports.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-sam_storage" || slbconfigs.slbInProdKingdom then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-portal",
        } + slbconfigs.ownerLabel,
        name: "slb-portal",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-portal",
                } + slbconfigs.ownerLabel,
                namespace: "sam-system",
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
                      ]),
                      containers: [
                          {
                              name: "slb-portal",
                              image: slbimages.hypersdn,
                              command: [
                                  "/sdn/slb-portal",
                                  "--hostname=$(NODE_NAME)",
                                  "--templatePath=" + slbconfigs.slbPortalTemplatePath,
                                  "--port=" + portconfigs.slb.slbPortalServicePort,
                                  "--client.serverInterface=lo",
                              ] + (if slbimages.hypersdn_build >= 947 then [
                                       "--keyfile=/etc/pki_service/platform/platform-client/keys/platform-client-key.pem",
                                       "--certfile=/etc/pki_service/platform/platform-client/certificates/platform-client.pem",
                                       "--log_dir=/host/data/slb/logs/slb-portal",
                                       "--cafile=/etc/pki_service/ca/cabundle.pem",
                                   ] + (if slbconfigs.isTestEstate then [
                                            "--slbEstate=" + configs.estate,
                                        ] else []) else []),
                              volumeMounts: configs.filter_empty(
                                  [
                                      slbconfigs.slb_volume_mount,
                                  ] + (if slbimages.hypersdn_build >= 947 then [
                                           configs.maddog_cert_volume_mount,
                                           configs.cert_volume_mount,
                                       ] else []),
                              ),
                              livenessProbe: {
                                  httpGet: {
                                      path: "/",
                                      port: portconfigs.slb.slbPortalServicePort,
                                  },
                                  initialDelaySeconds: 30,
                                  periodSeconds: 3,
                                  timeoutSeconds: 10,
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
                          slbshared.slbNodeApi(slbports.slb.slbNodeApiPort),
                          slbshared.slbLogCleanup,
                      ],
                      nodeSelector: {
                          "slb-dns-register": "true",
                      },
                  }
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
