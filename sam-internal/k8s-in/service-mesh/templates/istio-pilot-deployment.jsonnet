local configs = import "config.jsonnet";
local hosts = import "sam/configs/hosts.jsonnet";
local istioConfigs = (import "service-mesh/istio-config.jsonnet") + { templateFilename:: std.thisFile };
local istioUtils = (import "service-mesh/istio-utils.jsonnet") + { templateFilename:: std.thisFile };
local istioImages = (import "service-mesh/istio-images.jsonnet") + { templateFilename:: std.thisFile };

configs.deploymentBase("mesh-control-plane") {
  metadata+: {
    name: "istio-pilot",
    namespace: "mesh-control-plane",
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
      spec: {
        serviceAccount: "istio-pilot-service-account",
        serviceAccountName: "istio-pilot-service-account",
        containers: [
          {
            name: "discovery",
            image: istioImages.pilot,
            imagePullPolicy: "IfNotPresent",
            args: [
              "discovery",
              "--secureGrpcAddr",
              ":15011",
            ],
            ports: [
              {
                containerPort: 8080,
              },
              {
                containerPort: 15010,
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
            ],
          },
        ],
        # In PRD only kubeapi (master) nodes get cluster-admin permission
        # In production, SAM control estate nodes get cluster-admin permission
        # TODO: Migrate to Service Account with cluster-admin privilege and deploy to istioConfigs.istioEstate.
        nodeSelector:
          if configs.kingdom == "prd" then {
            master: "true",
          } else {
            pool: configs.estate,
          },
        volumes+: [
          {
            name: "config-volume",
            configMap: {
              name: "istio",
            },
          },
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
