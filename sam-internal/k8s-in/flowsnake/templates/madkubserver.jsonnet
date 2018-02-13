local flowsnakeimage = import "flowsnake_images.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
{
  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  metadata: {
    name: "madkubserver",
    namespace: "flowsnake",
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
        containers: [
          {
            args: [
              "/sam/madkub-server",
              "--listen",
              "0.0.0.0:32007",
              "-d",
              "--maddog-endpoint",
              "https://all.pkicontroller.pki.blank." + kingdom + ".prod.non-estates.sfdcsd.net:8443",
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
              "madkubserver",
              "--funnel-endpoint",
              "http://ajna0-funnel1-0-prd.data.sfdc.net:80",
              "--kingdom",
              kingdom,
              "--estate",
              estate,
            ],
            image: flowsnakeimage.madkub,
            name: "madkubserver",
            ports: [
              {
                containerPort: 3000,
              },
            ],
            volumeMounts: [
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
            ],
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
              "https://all.pkicontroller.pki.blank." + kingdom + ".prod.non-estates.sfdcsd.net:8443",
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
              "http://ajna0-funnel1-0-prd.data.sfdc.net:80",
              "--kingdom",
              kingdom,
              "--cert-folders",
              "madkubInternalCert:/certs/",
            ],
            image: flowsnakeimage.madkub,
            resources: {
            },
            volumeMounts: [
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
            ],
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
        volumes: [
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
        ],
      },
    },
  },
}
