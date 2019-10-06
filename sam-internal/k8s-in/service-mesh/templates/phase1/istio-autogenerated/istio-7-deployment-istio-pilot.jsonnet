# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
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
        maxSurge: 3,
        maxUnavailable: 1,
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
          cluster: mcpIstioConfig.istioEstate,
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
                value: "100ms",
              },
              {
                name: "PILOT_DEBOUNCE_MAX",
                value: "10s",
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
                name: "PILOT_PUSH_THROTTLE",
                value: "100",
              },
              {
                name: "PILOT_TRACE_SAMPLING",
                value: "1",
              },
              {
                name: "PILOT_ENABLE_PROTOCOL_SNIFFING_FOR_OUTBOUND",
                value: "true",
              },
              {
                name: "PILOT_ENABLE_PROTOCOL_SNIFFING_FOR_INBOUND",
                value: "false",
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
              "--envoyMetricsService",
              "{\"address\":\"switchboard.service-mesh:15001\",\"tls_settings\":{\"mode\":2,\"client_certificate\":\"/client-certs/client/certificates/client.pem\",\"private_key\":\"/client-certs/client/keys/client-key.pem\",\"ca_certificates\":\"/client-certs/ca.pem\"},\"tcp_keepalive\":{\"probes\":3,\"time\":{\"seconds\":10},\"interval\":{\"seconds\":10}}}",
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
              {
                name: "ISTIO_META_kubernetes_cluster_name",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "metadata.labels['cluster']",
                  },
                },
              },
              {
                name: "ESTATE",
                value: mcpIstioConfig.istioEstate,
              },
              {
                name: "KINGDOM",
                value: mcpIstioConfig.kingdom,
              },
              {
                name: "SDS_ENABLED",
                value: "false",
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
            securityContext: {
              runAsUser: 7557,
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
          {
            args: [
              "-p",
              "15002",
              "-z",
              "15006",
              "-u",
              "7557",
              "-m",
              "REDIRECT",
              "-i",
              "127.1.2.3/32",
              "-x",
              "",
              "-b",
              "",
              "-d",
              "15010,15011",
            ],
            env: [
              {
                name: "DISABLE_REDIRECTION_ON_LOCAL_LOOPBACK",
                value: "1",
              },
            ],
            image: mcpIstioConfig.proxyInitImage,
            imagePullPolicy: "IfNotPresent",
            name: "istio-init",
            resources: {
              limits: {
                cpu: "100m",
                memory: "50Mi",
              },
              requests: {
                cpu: "10m",
                memory: "10Mi",
              },
            },
            securityContext: {
              capabilities: {
                add: [
                  "NET_ADMIN",
                ],
              },
              runAsNonRoot: false,
              runAsUser: 0,
            },
            terminationMessagePath: "/dev/termination-log",
            terminationMessagePolicy: "File",
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
