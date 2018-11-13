local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";
local istioImages = (import "istio-images.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate != "prd-sam" then
// Skip for prd-sam. For PRD, we will be deploying to prd-sam_gater pool.
  configs.deploymentBase("service-mesh") {
    metadata+: {
      name: "istio-pilot",
      namespace: "service-mesh",
      labels: {
        istio: "pilot",
      } + istioUtils.istioLabels,
      annotations: {
        "checksum/config-volume": "f8da08b6b8c170dde721efd680270b2901e750d4aa186ebb6c22bef5b78a43f9",
      },
    },
    spec+: {
      replicas: 1,
      template: {
        metadata: {
          labels: {
            apptype: "control",
            istio: "pilot",
          } + istioUtils.istioLabels,
          annotations: {
            "sidecar.istio.io/inject": "false",
            "scheduler.alpha.kubernetes.io/critical-pod": "",
          },
        },
        spec: configs.specWithKubeConfigAndMadDog {
  //        serviceAccount: "istio-pilot-service-account",
  //        serviceAccountName: "istio-pilot-service-account",
          containers: [
            configs.containerWithKubeConfigAndMadDog {
              name: "discovery",
              image: istioImages.pilot,
              imagePullPolicy: "IfNotPresent",
              args: [
                "discovery",
                "--secureGrpcAddr",
                ":15011",
                "--kubeconfig",
                "/kubeconfig/kubeconfig-platform",
              ],
              ports: [
                {
                  containerPort: 8080,
                },
                {
                  containerPort: 15005,
                },
                {
                  containerPort: 15011,
                },
              ],
              readinessProbe: {
                httpGet: {
                  path: "/ready",
                  port: 8080,
                },
                initialDelaySeconds: 5,
                periodSeconds: 30,
                timeoutSeconds: 5,
              },
              env+: [
                {
                  name: "POD_NAME",
                  valueFrom: {
                    fieldRef: {
                      apiVersion: "v1",
                      fieldPath: "metadata.name",
                    },
                  },
                },
                {
                  name: "POD_NAMESPACE",
                  valueFrom: {
                    fieldRef: {
                      apiVersion: "v1",
                      fieldPath: "metadata.namespace",
                    },
                  },
                },
                {
                  name: "PILOT_CACHE_SQUASH",
                  value: "5",
                },
                {
                  name: "GODEBUG",
                  value: "gctrace=2",
                },
                {
                  name: "PILOT_PUSH_THROTTLE_COUNT",
                  value: "100",
                },
                {
                  name: "PILOT_TRACE_SAMPLING",
                  value: "100",
                },
              ],
              resources: {
                requests: {
                  cpu: "500m",
                  memory: "2048Mi",
                },
              },
              volumeMounts+: [
                {
                  name: "config-volume",
                  mountPath: "/etc/istio/config",
                },
  //              {
  //                name: "istio-certs",
  //                mountPath: "/etc/certs",
  //                readOnly: true,
  //              },
              ],
            },
          ],
          # In PRD only kubeapi (master) nodes get cluster-admin permission
          # In production, SAM control estate nodes get cluster-admin permission
          nodeSelector: {} +
            if configs.estate == "prd-samtest" then {
                master: "true",  # In PRD only kubeapi nodes get cluster-admin permission.
            } else {
                pool: configs.estate,  # Deploy to the sam_gater estate for others (We would use prd-sam_gater pool in PRD).
            },
          volumes+: [
            {
              name: "config-volume",
              configMap: {
                name: "istio",
              },
            },
  //          {
  //            name: "istio-certs",
  //            secret: {
  //              secretName: "istio.istio-pilot-service-account",
  //              optional: true,
  //            },
  //          },
          ],
          affinity: {
            nodeAffinity: {
              requiredDuringSchedulingIgnoredDuringExecution: {
                nodeSelectorTerms: [
                  {
                    matchExpressions: [
                      {
                        key: "beta.kubernetes.io/arch",
                        operator: "In",
                        values: [
                          "amd64",
                          "ppc64le",
                          "s390x",
                        ],
                      },
                    ],
                  },
                ],
              },
              preferredDuringSchedulingIgnoredDuringExecution: [
                {
                  weight: 2,
                  preference: {
                    matchExpressions: [
                      {
                        key: "beta.kubernetes.io/arch",
                        operator: "In",
                        values: [
                          "amd64",
                        ],
                      },
                    ],
                  },
                },
                {
                  weight: 2,
                  preference: {
                    matchExpressions: [
                      {
                        key: "beta.kubernetes.io/arch",
                        operator: "In",
                        values: [
                          "ppc64le",
                        ],
                      },
                    ],
                  },
                },
                {
                  weight: 2,
                  preference: {
                    matchExpressions: [
                      {
                        key: "beta.kubernetes.io/arch",
                        operator: "In",
                        values: [
                          "s390x",
                        ],
                      },
                    ],
                  },
                },
              ],
            },
          },
        },
      },
    },
  }
else "SKIP"
