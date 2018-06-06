local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-portaltwo" };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-portaltwo" };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-portaltwo",
        },
        name: "slb-portaltwo",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-portaltwo",
                },
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
                              name: "slb-portaltwo",
                              image: slbimages.hypersdn,
                              command: [
                                           "/sdn/slb-portal",
                                           "--hostname=$(NODE_NAME)",
                                           "--templatePath=" + slbconfigs.slbPortalTemplatePath,
                                           "--port=" + portconfigs.slb.slbPortalServicePort,
                                           "--keyfile=" + configs.keyFile,
                                           "--certfile=" + configs.certFile,
                                           "--cafile=" + configs.caFile,
                                           "--log_dir=" + slbconfigs.logsDir,
                                           "--client.serverInterface=lo",
                                       ],
                              volumeMounts: configs.filter_empty([
                                  configs.maddog_cert_volume_mount,
                                  configs.cert_volume_mount,
                                  slbconfigs.slb_volume_mount,
                              ]),
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
                          slbshared.slbConfigProcessor,
                          slbshared.slbCleanupConfig,
                          slbshared.slbNodeApi,
                          slbshared.slbLogCleanup,
                      ],
                      nodeSelector: {
                          pool: configs.estate,
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
