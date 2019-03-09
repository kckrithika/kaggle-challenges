# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  metadata: {
    labels: {
      app: "sidecarInjectorWebhook",
      istio: "sidecar-injector",
      release: "istio",
    },
    name: "istio-sidecar-injector",
    namespace: "mesh-control-plane",
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: {
        istio: "sidecar-injector",
        "sam.data.sfdc.net/owner": "mesh-control-plane",
      },
    },
    template: {
      metadata: {
        annotations: {
          "madkub.sam.sfdc.net/allcerts": mcpIstioConfig.sidecarInjectorMadkubAnnotations,
          "scheduler.alpha.kubernetes.io/critical-pod": "",
          "sidecar.istio.io/inject": "false",
        },
        labels: {
          istio: "sidecar-injector",
          "sam.data.sfdc.net/owner": "mesh-control-plane",
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
              "--caCertFile=/cert1/ca.pem",
              "--tlsCertFile=/cert1/server/certificates/server.pem",
              "--tlsKeyFile=/cert1/server/keys/server-key.pem",
              "--injectConfig=/etc/istio/inject/config",
              "--meshConfig=/etc/istio/config/mesh",
              "--healthCheckInterval=2s",
              "--healthCheckFile=/health",
              "--port=15009",
            ],
            image: mcpIstioConfig.sidecarInjectorImage,
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
              requests: {
                cpu: "10m",
              },
            },
            volumeMounts: [
              {
                mountPath: "/etc/pki_service",
                name: "maddog-certs",
              },
              {
                mountPath: "/cert1",
                name: "cert1",
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
              "--cert-folders=cert1:/cert1/",
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
            ],
            image: mcpIstioConfig.madkubImage,
            imagePullPolicy: "IfNotPresent",
            name: "madkub-refresher",
            resources: {},
            volumeMounts: [
              {
                mountPath: "/cert1",
                name: "cert1",
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
              "--cert-folders=cert1:/cert1/",
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
                mountPath: "/cert1",
                name: "cert1",
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
            name: "cert1",
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
