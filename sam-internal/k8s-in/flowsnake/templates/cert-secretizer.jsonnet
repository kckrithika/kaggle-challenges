local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnakeconfigmapmount = import "flowsnake_configmap_mount.jsonnet";
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
            "madkub.sam.sfdc.net/allcerts": if flowsnakeconfig.is_test then
                std.toString({ certreqs: [{ name: "ingresscerts", role: "flowsnake." + flowsnakeconfig.fleet_api_roles[estate], san: [flowsnakeconfig.fleet_vips[estate], flowsnakeconfig.fleet_api_roles[estate] + ".flowsnake.localhost.mesh.force.com"], "cert-type": "server", kingdom: kingdom }] })
            else
                std.toString({ certreqs: [{ name: "ingresscerts", role: "flowsnake", san: [flowsnakeconfig.fleet_vips[estate]], "cert-type": "server", kingdom: kingdom }] }),
        },
        labels: {
          name: "cert-secretizer",
        },
      },
      spec: {
        containers: [
            {
            name: "cert-secretizer",
            image: flowsnakeimage.cert_secretizer,
            volumeMounts: [
              {
                mountPath: "/certToSecretConfigs",
                name: "certs-to-secrets",
              },
              {
                mountPath: "/certs",
                name: "datacerts",
              },
              {
                mountPath: "/etc/flowsnake/config/auth-namespaces",
                name: "auth-namespaces",
                readOnly: true,
              },
            ] +
            flowsnakeconfigmapmount.kubeconfig_volumeMounts +
            flowsnakeconfigmapmount.platform_cert_volumeMounts,
            env: [
              {
                name: "FLOWSNAKE_FLEET",
                valueFrom: {
                  configMapKeyRef: {
                    name: "fleet-config",
                    key: "name",
                  },
                },
              },
              {
                name: "KUBECONFIG",
                valueFrom: {
                  configMapKeyRef: {
                    name: "fleet-config",
                    key: "kubeconfig",
                  },
                 },
              },
            ],
          },
          {
            name: "sam-madkub-integration-refresher",
            args: [
              "/sam/madkub-client",
              "--madkub-endpoint",
              "https://10.254.208.254:32007",  // TODO: Fix kubedns so we do not need the IP
              "--maddog-endpoint",
              "https://all.pkicontroller.pki.blank." + kingdom + ".prod.non-estates.sfdcsd.net:8443",
              "--maddog-server-ca",
              "/etc/pki_service/ca/security-ca.pem",
              "--madkub-server-ca",
              "/etc/pki_service/ca/cacerts.pem",
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
            ] + flowsnakeconfigmapmount.platform_cert_volumeMounts,
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
              "https://10.254.208.254:32007",  // TODO: Fix kubedns so we do not need the IP
              "--maddog-endpoint",
              "https://all.pkicontroller.pki.blank." + kingdom + ".prod.non-estates.sfdcsd.net:8443",
              "--maddog-server-ca",
              "/etc/pki_service/ca/security-ca.pem",
              "--madkub-server-ca",
              "/etc/pki_service/ca/cacerts.pem",
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
            ] + flowsnakeconfigmapmount.platform_cert_volumeMounts,
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
            name: "certs-to-secrets",
            configMap: {
              name: "certs-to-secrets",
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
          {
            name: "auth-namespaces",
            configMap: {
              name: "auth-namespaces",
            },
          },
        ] +
        flowsnakeconfigmapmount.platform_cert_volume +
        flowsnakeconfigmapmount.kubeconfig_platform_volume,
      },
    },
  },
}
