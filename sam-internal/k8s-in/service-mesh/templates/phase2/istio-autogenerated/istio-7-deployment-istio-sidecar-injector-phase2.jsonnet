# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 2) then
{
  apiVersion: "apps/v1",
  kind: "Deployment",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "sidecarInjectorWebhook",
      istio: "sidecar-injector",
      release: "istio",
    },
    name: "istio-sidecar-injector",
    namespace: "mesh-control-plane",
  },
  spec: {
    replicas: 3,
    selector: {
      matchLabels: {
        istio: "sidecar-injector",
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
          "madkub.sam.sfdc.net/allcerts": mcpIstioConfig.sidecarInjectorMadkubAnnotations,
          "sidecar.istio.io/inject": "false",
        },
        labels: {
          app: "sidecarInjectorWebhook",
          chart: "sidecarInjectorWebhook",
          cluster: mcpIstioConfig.istioEstate,
          heritage: "Tiller",
          istio: "sidecar-injector",
          name: "istio-sidecar-injector",
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
              "--caCertFile=/server-cert/ca.pem",
              "--tlsCertFile=/server-cert/server/certificates/server.pem",
              "--tlsKeyFile=/server-cert/server/keys/server-key.pem",
              "--injectConfig=/etc/istio/inject/config",
              "--meshConfig=/etc/istio/config/mesh",
              "--healthCheckInterval=2s",
              "--healthCheckFile=/health",
              "--port=15009",
            ],
            env: [
              {
                name: "ESTATE",
                value: mcpIstioConfig.istioEstate,
              },
            ],
            image: "%(istioHub)s/sidecar_injector:%(istioTag)s" % mcpIstioConfig,
            imagePullPolicy: "IfNotPresent",
            livenessProbe: {
              exec: {
                command: [
                  "/usr/local/bin/sidecar-injector",
                  "probe",
                  "--probe-path=/health",
                  "--interval=4s",
                ],
              },
              initialDelaySeconds: 4,
              periodSeconds: 4,
            },
            name: "sidecar-injector-webhook",
            ports: [
              {
                containerPort: 15009,
              },
            ],
            readinessProbe: {
              exec: {
                command: [
                  "/usr/local/bin/sidecar-injector",
                  "probe",
                  "--probe-path=/health",
                  "--interval=4s",
                ],
              },
              initialDelaySeconds: 4,
              periodSeconds: 4,
            },
            resources: {
              limits: {
                cpu: "1000m",
                memory: "256Mi",
              },
              requests: {
                cpu: "100m",
                memory: "128Mi",
              },
            },
            volumeMounts: [
              {
                mountPath: "/etc/pki_service",
                name: "maddog-certs",
              },
              {
                mountPath: "/server-cert",
                name: "tls-server-cert",
              },
              {
                mountPath: "/etc/istio/config",
                name: "config-volume",
                readOnly: true,
              },
              {
                mountPath: "/etc/istio/inject",
                name: "inject-config",
                readOnly: true,
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
              "--cert-folders=tls-server-cert:/server-cert/",
              "--token-folder=/tokens/",
              "--requested-cert-type=client",
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
        ],
        initContainers: [
          {
            args: [
              "/sam/madkub-client",
              "--madkub-endpoint=%(madkubEndpoint)s" % mcpIstioConfig,
              "--maddog-endpoint=%(maddogEndpoint)s" % mcpIstioConfig,
              "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
              "--cert-folders=tls-server-cert:/server-cert/",
              "--token-folder=/tokens/",
              "--requested-cert-type=client",
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
          master: "true",
        },
        serviceAccountName: "istio-sidecar-injector-service-account",
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
          {
            configMap: {
              items: [
                {
                  key: "config",
                  path: "config",
                },
                {
                  key: "values",
                  path: "values",
                },
              ],
              name: "istio-sidecar-injector",
            },
            name: "inject-config",
          },
        ],
      },
    },
  },
}

else "SKIP"
