# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 2) then
{
  apiVersion: "apps/v1",
  kind: "Deployment",
  metadata: {
    annotations: {
      "checksum/config-volume": "f8da08b6b8c170dde721efd680270b2901e750d4aa186ebb6c22bef5b78a43f9",
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
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
    replicas: 3,
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
          "madkub.sam.sfdc.net/allcerts": mcpIstioConfig.pilotMadkubAnnotations,
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
              "--log_output_level=default:warn",
              "--domain",
              "cluster.local",
              "--keepaliveMaxServerConnectionAge",
              "30m",
              "--secureGrpcAddr=",
            ],
            env: [
              {
                name: "ESTATE",
                value: mcpIstioConfig.istioEstate,
              },
              {
                name: "PILOT_SIDECAR_USE_REMOTE_ADDRESS",
                value: "true",
              },
              {
                name: "PILOT_ENABLE_REDIS_FILTER",
                value: "true",
              },
              {
                name: "PILOT_DEBOUNCE_AFTER",
                value: "1m",
              },
              {
                name: "PILOT_DEBOUNCE_MAX",
                value: "3m",
              },
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
                value: "10",
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
            image: "%(istioHub)s/pilot:%(istioTag)s" % mcpIstioConfig,
            imagePullPolicy: "IfNotPresent",
            name: "discovery",
            ports: [
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
              limits: {
                cpu: "2000m",
                memory: "4096Mi",
              },
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
              "proxy",
              "--domain",
              "$(POD_NAMESPACE).svc.cluster.local",
              "--serviceCluster",
              "istio-pilot",
              "--templateFile",
              "/etc/istio/proxy/envoy_pilot.yaml.tmpl",
              "--controlPlaneAuthPolicy",
              "MUTUAL_TLS",
              "--envoyMetricsServiceAddress",
              "switchboard.service-mesh:15001",
              "--proxyAdminPort",
              "15373",
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
                name: "INSTANCE_IP",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "status.podIP",
                  },
                },
              },
              {
                name: "ISTIO_META_hostname",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "metadata.name",
                  },
                },
              },
              {
                name: "ISTIO_META_namespace",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "metadata.namespace",
                  },
                },
              },
              {
                name: "ISTIO_METAJSON_METRICS_INCLUSIONS",
                value: "{\"sidecar.istio.io/statsInclusionPrefixes\": \"access_log_file,cluster,cluster_manager,control_plane,http,http2,http_mixer_filter,listener,listener_manager,redis,runtime,server,stats,tcp,tcp_mixer_filter,tracing\"}",
              },
              {
                name: "ISTIO_META_TLS_CLIENT_CERT_CHAIN",
                value: "/client-certs/client/certificates/client.pem",
              },
              {
                name: "ISTIO_META_TLS_CLIENT_KEY",
                value: "/client-certs/client/keys/client-key.pem",
              },
              {
                name: "ISTIO_META_TLS_CLIENT_ROOT_CERT",
                value: "/client-certs/ca.pem",
              },
              {
                name: "ISTIO_META_TLS_SERVER_CERT_CHAIN",
                value: "/server-certs/server/certificates/server.pem",
              },
              {
                name: "ISTIO_META_TLS_SERVER_KEY",
                value: "/server-certs/server/keys/server-key.pem",
              },
              {
                name: "ISTIO_META_TLS_SERVER_ROOT_CERT",
                value: "/server-certs/ca.pem",
              },
            ],
            image: "%(istioHub)s/proxy:%(istioTag)s" % mcpIstioConfig,
            imagePullPolicy: "IfNotPresent",
            name: "istio-proxy",
            ports: [
              {
                containerPort: 15003,
              },
              {
                containerPort: 15005,
              },
              {
                containerPort: 15007,
              },
              {
                containerPort: 15011,
              },
            ],
            resources: {
              limits: {
                cpu: "2000m",
                memory: "1024Mi",
              },
              requests: {
                cpu: "100m",
                memory: "128Mi",
              },
            },
            volumeMounts: [
              {
                mountPath: "/client-certs",
                name: "tls-client-cert",
              },
              {
                mountPath: "/server-certs",
                name: "tls-server-cert",
              },
            ],
          },
          {
            args: [
              "/sam/madkub-client",
              "--madkub-endpoint=%(madkubEndpoint)s" % mcpIstioConfig,
              "--maddog-endpoint=%(maddogEndpoint)s" % mcpIstioConfig,
              "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
              "--cert-folders=tls-client-cert:/client-cert/",
              "--cert-folders=tls-server-cert:/server-cert/",
              "--token-folder=/tokens/",
              "--ca-folder=/maddog-certs/ca",
              "--refresher",
              "--run-init-for-refresher-mode",
            ],
            env: [
              {
                name: "MADKUB_NODENAME",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "spec.nodeName",
                  },
                },
              },
              {
                name: "MADKUB_NAME",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.name",
                  },
                },
              },
              {
                name: "MADKUB_NAMESPACE",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.namespace",
                  },
                },
              },
              {
                name: "ESTATE",
                value: mcpIstioConfig.istioEstate,
              },
            ],
            image: mcpIstioConfig.madkubImage,
            imagePullPolicy: "IfNotPresent",
            name: "madkub-refresher",
            resources: {},
            volumeMounts: [
              {
                mountPath: "/client-cert",
                name: "tls-client-cert",
              },
              {
                mountPath: "/server-cert",
                name: "tls-server-cert",
              },
              {
                mountPath: "/maddog-certs/",
                name: "maddog-certs",
              },
              {
                mountPath: "/tokens",
                name: "tokens",
              },
            ],
          },
          {
            args: [
              "--debug-mode",
              "true",
              "--funnel-address",
              mcpIstioConfig.funnelEndpoint,
              "--alt-tags",
              "cluster=svccluster",
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
                value: mcpIstioConfig.pilotSettingsPath,
              },
              {
                name: "ESTATE",
                value: mcpIstioConfig.istioEstate,
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
            resources: {
              limits: {
                cpu: "2000m",
                memory: "2048Mi",
              },
              requests: {
                cpu: "100m",
                memory: "512Mi",
              },
            },
          },
        ],
        initContainers: [
          {
            args: [
              "/sam/madkub-client",
              "--madkub-endpoint=%(madkubEndpoint)s" % mcpIstioConfig,
              "--maddog-endpoint=%(maddogEndpoint)s" % mcpIstioConfig,
              "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
              "--cert-folders=tls-client-cert:/client-cert/",
              "--cert-folders=tls-server-cert:/server-cert/",
              "--token-folder=/tokens/",
              "--ca-folder=/maddog-certs/ca",
            ],
            env: [
              {
                name: "MADKUB_NODENAME",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "spec.nodeName",
                  },
                },
              },
              {
                name: "MADKUB_NAME",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.name",
                  },
                },
              },
              {
                name: "MADKUB_NAMESPACE",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.namespace",
                  },
                },
              },
            ],
            image: mcpIstioConfig.madkubImage,
            imagePullPolicy: "IfNotPresent",
            name: "madkub-init",
            volumeMounts: [
              {
                mountPath: "/client-cert",
                name: "tls-client-cert",
              },
              {
                mountPath: "/server-cert",
                name: "tls-server-cert",
              },
              {
                mountPath: "/maddog-certs/",
                name: "maddog-certs",
              },
              {
                mountPath: "/tokens",
                name: "tokens",
              },
            ],
          },
          {
            command: [
              "bash",
              "-c",
              "set -ex\nchmod 775 -R /client-cert \u0026\u0026 chown -R 7447:7447 /client-cert\nchmod 775 -R /server-cert \u0026\u0026 chown -R 7447:7447 /server-cert\n",
            ],
            image: mcpIstioConfig.permissionInitContainer,
            imagePullPolicy: "Always",
            name: "permissionsetterinitcontainer",
            securityContext: {
              runAsNonRoot: false,
              runAsUser: 0,
            },
            volumeMounts: [
              {
                mountPath: "/client-cert",
                name: "tls-client-cert",
              },
              {
                mountPath: "/server-cert",
                name: "tls-server-cert",
              },
            ],
          },
        ],
        nodeSelector: {
          pool: mcpIstioConfig.istioEstate,
        },
        serviceAccountName: "istio-pilot-service-account",
        volumes: [
          {
            hostPath: {
              path: "/etc/pki_service",
            },
            name: "maddog-certs",
          },
          {
            emptyDir: {
              medium: "Memory",
            },
            name: "tls-client-cert",
          },
          {
            emptyDir: {
              medium: "Memory",
            },
            name: "tls-server-cert",
          },
          {
            emptyDir: {
              medium: "Memory",
            },
            name: "tokens",
          },
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

else "SKIP"
