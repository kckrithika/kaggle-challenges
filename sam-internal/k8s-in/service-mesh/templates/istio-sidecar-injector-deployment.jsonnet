local configs = import "config.jsonnet";
local istioImages = (import "service-mesh/istio-images.jsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "service-mesh/istio-madkub.jsonnet") + { templateFilename:: std.thisFile };

local certDirs = ["cert1"];

local webhookCerts = {
  caFile: "/cert1/ca.pem",
  certFile: "/cert1/server/certificates/server.pem",
  keyFile: "/cert1/server/keys/server-key.pem",
};

configs.deploymentBase("mesh-control-plane") {
  metadata+: {
    name: "istio-sidecar-injector",
    namespace: "mesh-control-plane",
    labels: {
      app: "sidecarInjectorWebhook",
      chart: "sidecarInjectorWebhook-1.0.1",
      istio: "sidecar-injector",
    },
  },
  spec+: {
    replicas: 2,
    template: {
      metadata: {
        labels: {
          istio: "sidecar-injector",
        },
        annotations: {
          "sidecar.istio.io/inject": "false",
          "scheduler.alpha.kubernetes.io/critical-pod": "",
          "madkub.sam.sfdc.net/allcerts":
          std.manifestJsonEx(
            {
              certreqs:
                [
                  certReq
                  for certReq in madkub.madkubIstioCertsAnnotation(certDirs).certreqs
                ],
            }, " "
          ),
        },
      },
      spec: configs.specWithMadDog {
        serviceAccountName: "istio-sidecar-injector-service-account",
        containers: [
          configs.containerWithMadDog {
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
              "--port=15009",
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
            ] + madkub.madkubIstioCertVolumeMounts(certDirs),
            ports: [
              {
                containerPort: 15009,
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
        ] + [madkub.madkubRefreshContainer(certDirs)],
        nodeSelector: {
          master: "true",
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
        ] + madkub.madkubIstioCertVolumes(certDirs)
          + madkub.madkubIstioMadkubVolumes(),
        initContainers+: [
          madkub.madkubInitContainer(certDirs),
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
