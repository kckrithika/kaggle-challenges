local configs = import "config.jsonnet";
local istioImages = (import "istio-images.jsonnet") + { templateFilename:: std.thisFile };

// Using host certificates for now.
local webhookCerts = {
  caFile: "/etc/pki_service/ca/cacerts.pem",
  certFile: "/etc/pki_service/kubernetes/k8s-server/certificates/k8s-server.pem",
  keyFile: "/etc/pki_service/kubernetes/k8s-server/keys/k8s-server-key.pem",
};

configs.deploymentBase("service-mesh") {
  metadata+: {
    name: "istio-sidecar-injector",
    namespace: "service-mesh",
    labels: {
      app: "sidecarInjectorWebhook",
      chart: "sidecarInjectorWebhook-1.0.1",
      release: "RELEASE-NAME",
      heritage: "Tiller",
      istio: "sidecar-injector",
    },
  },
  spec+: {
    replicas: 1,
    template: {
      metadata: {
        labels: {
          istio: "sidecar-injector",
        },
        annotations: {
          "sidecar.istio.io/inject": "false",
          "scheduler.alpha.kubernetes.io/critical-pod": "",
        },
      },
      spec: configs.specWithKubeConfigAndMadDog {
//        serviceAccountName: "istio-sidecar-injector-service-account",
        containers: [
          configs.containerWithKubeConfigAndMadDog {
            name: "sidecar-injector-webhook",
            image: istioImages.sidecarinjector,
            imagePullPolicy: "IfNotPresent",
            args: [
              "--caCertFile=%s" % webhookCerts.caFile,
              "--tlsCertFile=%s" % webhookCerts.certFile,
              "--tlsKeyFile=%s" % webhookCerts.keyFile,
              "--injectConfig=/etc/istio/inject/config",
              "--meshConfig=/etc/istio/config/mesh",
              "--healthCheckInterval=2s",
              "--healthCheckFile=/health",
            ],
            volumeMounts+: [
              {
                name: "config-volume",
                mountPath: "/etc/istio/config",
                readOnly: true,
              },
//              {
//                name: "certs",
//                mountPath: "/etc/istio/certs",
//                readOnly: true,
//              },
              {
                name: "inject-config",
                mountPath: "/etc/istio/inject",
                readOnly: true,
              },
            ],
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
          },
        ],
        # In PRD only kubeapi (master) nodes get cluster-admin permission
        # In production, SAM control estate nodes get cluster-admin permission
        nodeSelector: {} +
          if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then {
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
//          {
//            name: "certs",
//            secret: {
//              secretName: "istio.istio-sidecar-injector-service-account",
//            },
//          },
          {
            name: "inject-config",
            configMap: {
              name: "istio-sidecar-injector",
              items: [
                {
                  key: "config",
                  path: "config",
                },
              ],
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
