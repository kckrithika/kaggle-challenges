local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
if !flowsnakeconfig.maddog_enabled then
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
            "madkub.sam.sfdc.net/allcerts": std.toString({ certreqs: [{ name: "ingresscerts", role: "flowsnake", san: [flowsnakeconfig.fleet_vips[estate]], "cert-type": "server", kingdom: kingdom }] }),
        },
        labels: {
          name: "cert-secretizer",
        },
      },
      spec: {
        containers: [
          {
            name: "sam-madkub-integration-refresher",
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
              flowsnakeconfig.funnel_endpoint,
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
                mountPath: "/maddog-certs",
                name: "pki",
              },
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
          },
        ],
        initContainers: [
          {
            name: "sam-madkub-integration-init",
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
              flowsnakeconfig.funnel_endpoint,
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
                mountPath: "/maddog-certs",
                name: "pki",
              },
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
