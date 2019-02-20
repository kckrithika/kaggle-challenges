local configs = import "config.jsonnet";
local hosts = import "sam/configs/hosts.jsonnet";
local istioConfigs = (import "service-mesh/istio-config.jsonnet") + { templateFilename:: std.thisFile };
local istioUtils = (import "service-mesh/istio-utils.jsonnet") + { templateFilename:: std.thisFile };
local istioImages = (import "service-mesh/istio-images.jsonnet") + { templateFilename:: std.thisFile };
local funnelEndpoint = std.split(configs.funnelVIP, ":");
local scraperImagePullPolicy = (if configs.kingdom == "prd" then "Always" else "IfNotPresent");

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
              "--appNamespace",
              "service-mesh",
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
          {
            name: "metrics-scraper",
            image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/servicemesh/metrics-scraper:dev",
            imagePullPolicy: scraperImagePullPolicy,
            readinessProbe: {
              exec: {
                command: [
                  "/bin/true",
                ],
              },
              initialDelaySeconds: 5,
              periodSeconds: 30,
              timeoutSeconds: 5,
            },
            args: if configs.kingdom == "prd" then [
              "--debug-mode",
              "true",
            ] else [],
            env: [
              // See https://confluence.internal.salesforce.com/pages/viewpage.action?spaceKey=SAM&title=SAM+Environment+Variables
              // for SAM environment variables.
              {
                name: "FUNCTION_NAMESPACE",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.namespace",
                  },
                },
              },
              {
                name: "SETTINGS_SUPERPOD",
                value: "-",
              },
              {
                name: "SETTINGS_PATH",
                value: "-.-." + configs.kingdom + ".-." + "istio-pilot",
              },
              {
                name: "SFDC_METRICS_SERVICE_HOST",
                value: funnelEndpoint[0],
              },
              {
                name: "SFDC_METRICS_SERVICE_PORT",
                value: funnelEndpoint[1],
              },
            ],
          },
        ],
        nodeSelector: {
          pool: istioConfigs.istioEstate,
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
