local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
local utils = import "util_functions.jsonnet";

if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then {
  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  metadata: {
    name: "madkubserver",
    namespace: "sam-system",
  },
  spec: {
    replicas: 3,
    minReadySeconds: 45,
    template: {
      metadata: {
        labels: {
          service: "madkubserver",
        },
      },
      spec: {
        nodeSelector: {
          master: "true",
        },
        containers: [
          {
            args: [
              "/sam/madkub-server",
              "--listen",
              "0.0.0.0:32007",
              "-d",
              "--maddog-endpoint",
              "https://all.pkicontroller.pki.blank." + configs.kingdom + ".prod.non-estates.sfdcsd.net:8443",
              "--kubeconfig",
              "/kubeconfig",
              "--client-cert",
              "/etc/pki_service/root/madkubtokenserver/certificates/madkubtokenserver.pem",
              "--client-key",
              "/etc/pki_service/root/madkubtokenserver/keys/madkubtokenserver-key.pem",
              "--maddog-server-ca",
              "/etc/pki_service/ca/security-ca.pem",
              "--cert-folder",
              "/certs/",
              "--token-folder",
              "/tokens/",
              "--service-hostname",
              "$(MADKUBSERVER_SERVICE_HOST)",
              "--funnel-endpoint",
              "http://" + configs.funnelVIP,
              "--kingdom",
              configs.kingdom,
            ] +
            if configs.estate == "prd-samdev" || configs.estate == "prd-samtest" || configs.estate == "prd-sam" || configs.estate == "prd-sdc" || configs.estate == "prd-sam_storage" then [
              "--estate",
              configs.estate,
            ] else [
            ],
            image: samimages.madkub,
            name: "madkubserver",
            ports: [
              {
                containerPort: 3000,
              },
            ],
            volumeMounts: configs.filter_empty([
              {
                mountPath: "/kubeconfig",
                name: "kubeconfig",
              },
              {
                mountPath: "/data/certs",
                name: "kubeconfig-certs",
              },
              {
                mountPath: "/certs",
                name: "datacerts",
              },
              {
                mountPath: "/tokens",
                name: "tokens",
              },
              {
                mountPath: "/etc/pki_service/",
                name: "pki",
              },
            ]),
            livenessProbe: {
              httpGet: {
                path: "/healthz",
                port: 32007,
                scheme: "HTTPS",
              },
              initialDelaySeconds: 30,
              periodSeconds: 10,
            },
          },
          {
            name: "madkub-refresher",
            args: [
              "/sam/madkub-client",
              "--madkub-endpoint",
              "",
              "--maddog-endpoint",
              "https://all.pkicontroller.pki.blank." + configs.kingdom + ".prod.non-estates.sfdcsd.net:8443",
              "--maddog-server-ca",
              "/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca",
              "/maddog-certs/ca/cacerts.pem",
              "--token-folder",
              "/tokens/",
              "--refresher",
              "--refresher-token-grace-period",
              "30s",

              "--funnel-endpoint",
              "http://" + configs.funnelVIP,
              "--kingdom",
              configs.kingdom,
            ] +
            if samimages.per_phase[samimages.phase].madkub == "1.0.0-0000035-9241ed31" then [
              "--cert-folder",
              "/certs/",
              "--requested-cert-type",
              "server",
              ] else [
              "--cert-folders",
              "madkubInternalCert:/certs/",
              ],
            image: samimages.madkub,
            resources: {
            },
            volumeMounts: configs.filter_empty([
              {
                mountPath: "/certs",
                name: "datacerts",
              },
              {
                mountPath: "/tokens",
                name: "tokens",
              },
              {
                mountPath: "/maddog-certs/",
                name: "pki",
              },
            ]),
            env: [
              {
                name: "MADKUB_NODENAME",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "spec.nodeName",
                  },
                },
              },
              {
                name: "MADKUB_NAME",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "metadata.name",
                  },
                },
              },
              {
                name: "MADKUB_NAMESPACE",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "metadata.namespace",
                  },
                },
              },
            ],
          },
        ],
        restartPolicy: "Always",
        volumes: configs.filter_empty([
          {
            name: "kubeconfig",
            hostPath: {
              path: "/etc/kubernetes/kubeconfig",
            },
          },
          {
            name: "kubeconfig-certs",
            hostPath: {
              path: "/data/certs",
            },
          },
          {
            name: "pki",
            hostPath: {
              path: "/etc/pki_service",
            },
          },
          {
            name: "datacerts",
            emptyDir: {
              medium: "Memory",
            },
          },
          {
            name: "tokens",
            emptyDir: {
              medium: "Memory",
            },
          },
        ]),
      },
    },
  },
} else "SKIP"
