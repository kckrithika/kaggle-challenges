# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  metadata: {
    annotations: {
      "checksum/config-volume": "f8da08b6b8c170dde721efd680270b2901e750d4aa186ebb6c22bef5b78a43f9",
    },
    labels: {
      app: "pilot",
      istio: "pilot",
      release: "istio",
    },
    name: "istio-pilot",
    namespace: "mesh-control-plane",
  },
  spec: {
    selector: {
      matchLabels: {
        app: "pilot",
        istio: "pilot",
      },
    },
    strategy: {
      rollingUpdate: {
        maxSurge: 1,
        maxUnavailable: 0,
      },
    },
    template: {
      metadata: {
        annotations: {
          "scheduler.alpha.kubernetes.io/critical-pod": "",
          "sidecar.istio.io/inject": "false",
        },
        labels: {
          app: "pilot",
          chart: "pilot",
          heritage: "Tiller",
          istio: "pilot",
          name: "istio-pilot",
          release: "istio",
        },
      },
      spec: {
        affinity: {
          nodeAffinity: {
            preferredDuringSchedulingIgnoredDuringExecution: [
              {
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
                weight: 2,
              },
              {
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
                weight: 2,
              },
              {
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
                weight: 2,
              },
            ],
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
          },
        },
        containers: [
          {
            args: [
              "discovery",
              "--monitoringAddr=:15014",
              "--domain",
              "cluster.local",
              "--secureGrpcAddr",
              "",
              "--keepaliveMaxServerConnectionAge",
              "30m",
              "--appNamespace",
              "service-mesh",
              "--log_output_level",
              "debug",
            ],
            env: [
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
                name: "GODEBUG",
                value: "gctrace=1",
              },
              {
                name: "PILOT_PUSH_THROTTLE",
                value: "100",
              },
              {
                name: "PILOT_TRACE_SAMPLING",
                value: "1",
              },
              {
                name: "PILOT_DISABLE_XDS_MARSHALING_TO_ANY",
                value: "1",
              },
            ],
            image: mcpIstioConfig.pilotImage,
            imagePullPolicy: "IfNotPresent",
            name: "discovery",
            ports: [
              {
                containerPort: 15011,
              },
              {
                containerPort: 8080,
              },
              {
                containerPort: 15010,
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
            resources: {
              requests: {
                cpu: "500m",
                memory: "2048Mi",
              },
            },
            volumeMounts: [
              {
                mountPath: "/etc/istio/config",
                name: "config-volume",
              },
            ],
          },
          {
            args: [
              "--debug-mode",
              "true",
            ],
            env: [
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
                value: mcpIstioConfig.superpod,
              },
              {
                name: "SETTINGS_PATH",
                value: mcpIstioConfig.settingsPath,
              },
              {
                name: "SFDC_METRICS_SERVICE_HOST",
                value: mcpIstioConfig.funnelHost,
              },
              {
                name: "SFDC_METRICS_SERVICE_PORT",
                value: mcpIstioConfig.funnelPort,
              },
            ],
            image: mcpIstioConfig.metricsScraperImage,
            imagePullPolicy: "Always",
            name: "metrics-scraper",
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
          },
        ],
        nodeSelector: {
          pool: mcpIstioConfig.istioEstate,
        },
        serviceAccountName: "istio-pilot-service-account",
        volumes: [
          {
            configMap: {
              name: "istio",
            },
            name: "config-volume",
          },
        ],
      },
    },
  },
}
