local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-sam_storage" || slbconfigs.slbInProdKingdom then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-portal",
        },
        name: "slb-portal",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-portal",
                },
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
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
                       ],
                       volumeMounts: configs.filter_empty([
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
    } + if slbimages.phase == "1" || slbimages.phase == "2" then {
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 1,
            },
        },
        minReadySeconds: 30,
    } else {},
} else "SKIP"
