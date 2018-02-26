local flowsnakeimage = import "flowsnake_images.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
if flowsnakeconfig.is_minikube then
"SKIP"
else
{
  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  metadata: {
    name: "cert-secretizer",
    namespace: "flowsnake",
  },
  spec: {
    replicas: 1,
    minReadySeconds: 45,
    template: {
      metadata: {
        annotations: {
            "madkub.sam.sfdc.net/allcerts": std.toString({ certreqs: [{ name: "ingresscerts", role: "samapp", san: ["test-fleet-fake-san-prd.data.sfdc.net"], "cert-type": "server", kingdom: kingdom }] }),
        },
        labels: {
          name: "cert-secretizer",
        },
      },
      spec: {
        containers: [
          {
            name: "madkub-refresher",
            args: [
              "/sam/madkub-client",
              "--madkub-endpoint",
              "https://10.254.208.254:32007",
              "--maddog-endpoint",
              "https://all.pkicontroller.pki.blank." + kingdom + ".prod.non-estates.sfdcsd.net:8443",
              "--maddog-server-ca",
              "/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca",
              "/maddog-certs/ca/cacerts.pem",
              "--token-folder",
              "/tokens",
              "--funnel-endpoint",
              "http://ajna0-funnel1-0-prd.data.sfdc.net:80",
              "--kingdom",
              kingdom,
              "--superpod",
              "None",
              "--estate",
              estate,
              "--refresher",
              "--run-init-for-refresher-mode",
              "--cert-folders",
              "ingresscerts:/certs",
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
        initContainers: [
          {
            name: "madkub-initer",
            args: [
              "/sam/madkub-client",
              "--madkub-endpoint",
              "https://10.254.208.254:32007",
              "--maddog-endpoint",
              "https://all.pkicontroller.pki.blank." + kingdom + ".prod.non-estates.sfdcsd.net:8443",
              "--maddog-server-ca",
              "/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca",
              "/maddog-certs/ca/cacerts.pem",
              "--token-folder",
              "/tokens",
              "--funnel-endpoint",
              "http://ajna0-funnel1-0-prd.data.sfdc.net:80",
              "--kingdom",
              kingdom,
              "--superpod",
              "None",
              "--estate",
              estate,
              "--cert-folders",
              "ingresscerts:/certs",
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
