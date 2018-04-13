local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnakeconfigmapmount = import "flowsnake_configmap_mount.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
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
            "madkub.sam.sfdc.net/allcerts": std.toString({ certreqs: [{ name: "ingresscerts", role: "flowsnake." + flowsnakeconfig.fleet_api_roles[estate], san: [flowsnakeconfig.fleet_vips[estate], flowsnakeconfig.fleet_api_roles[estate] + ".flowsnake.localhost.mesh.force.com"], "cert-type": "server", kingdom: kingdom }] }),
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
            imagePullPolicy: if flowsnakeconfig.is_minikube then "Never" else "Always",
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
            (if !flowsnakeconfig.is_minikube then
                flowsnakeconfigmapmount.kubeconfig_volumeMounts +
                flowsnakeconfigmapmount.platform_cert_volumeMounts
            else []),
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
              if flowsnakeconfig.is_minikube then "https://madkubserver:32007" else "https://10.254.208.254:32007",  // TODO: Fix kubedns so we do not need the IP
              "--maddog-endpoint",
              if flowsnakeconfig.is_minikube then "https://maddog-onebox:8443" else "https://all.pkicontroller.pki.blank." + kingdom + ".prod.non-estates.sfdcsd.net:8443",
              "--maddog-server-ca",
              if flowsnakeconfig.is_minikube then "/sc/ca/security-ca.pem" else "/etc/pki_service/ca/security-ca.pem",
              "--madkub-server-ca",
              if flowsnakeconfig.is_minikube then "/sc/ca/ca.pem" else "/etc/pki_service/ca/cacerts.pem",
              "--token-folder",
              "/tokens",
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
            ] +
            (if !flowsnakeconfig.is_minikube then [
              "--funnel-endpoint",
              flowsnakeconfig.funnel_endpoint,
            ] else []),
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
            ] +
            (if !flowsnakeconfig.is_minikube then
                flowsnakeconfigmapmount.platform_cert_volumeMounts
            else [
                {
                  mountPath: "/sc",
                  name: "maddog-onebox-certs",
                },
            ]),
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
              if flowsnakeconfig.is_minikube then "https://madkubserver:32007" else "https://10.254.208.254:32007",  // TODO: Fix kubedns so we do not need the IP
              "--maddog-endpoint",
              if flowsnakeconfig.is_minikube then "https://maddog-onebox:8443" else "https://all.pkicontroller.pki.blank." + kingdom + ".prod.non-estates.sfdcsd.net:8443",
              "--maddog-server-ca",
              if flowsnakeconfig.is_minikube then "/sc/ca/security-ca.pem" else "/etc/pki_service/ca/security-ca.pem",
              "--madkub-server-ca",
              if flowsnakeconfig.is_minikube then "/sc/ca/ca.pem" else "/etc/pki_service/ca/cacerts.pem",
              "--token-folder",
              "/tokens",
              "--kingdom",
              kingdom,
              "--superpod",
              "None",
              "--estate",
              estate,
              "--cert-folders",
              "ingresscerts:/certs",
            ] +
            (if !flowsnakeconfig.is_minikube then [
              "--funnel-endpoint",
              flowsnakeconfig.funnel_endpoint,
            ] else []),
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
            ] +
            (if !flowsnakeconfig.is_minikube then
                flowsnakeconfigmapmount.platform_cert_volumeMounts
            else [
                {
                  mountPath: "/sc",
                  name: "maddog-onebox-certs",
                },
            ]),
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
        (if !flowsnakeconfig.is_minikube then
            flowsnakeconfigmapmount.platform_cert_volume +
            flowsnakeconfigmapmount.kubeconfig_platform_volume
        else [
            {
              hostPath: {
                  path: "/tmp/sc_repo",
              },
              name: "maddog-onebox-certs",
            },
        ]),
      },
    },
  },
}
