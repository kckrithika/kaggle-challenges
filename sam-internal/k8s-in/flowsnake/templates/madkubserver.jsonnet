local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local configs = import "config.jsonnet";
local old_062_image = !std.objectHas(flowsnake_images.feature_flags, "madkub_077_upgrade");
local utils = import "util_functions.jsonnet";

configs.deploymentBase("flowsnake") {
  local label_node = self.spec.template.metadata.labels,
  metadata: {
    labels: {
        service: "madkubserver",
    },
    name: "madkubserver",
    namespace: "flowsnake",
  },
  spec+: {
    replicas: if flowsnakeconfig.is_minikube then 1 else 3,
    minReadySeconds: 45,
    selector: {
      matchLabels: {
        service: label_node.service,
      },
    },
    template: {
      metadata: {
        labels: {
          service: "madkubserver",
          flowsnakeOwner: "dva-transform",
          flowsnakeRole: "MadkubServer",
        },
      },
      spec: {
        hostNetwork: if utils.is_public_cloud(configs.kingdom) then true else false,
        containers: [
          {
            args: [
              "/sam/madkub-server",
              "--listen",
              "0.0.0.0:32007",
              "-d",
              "--maddog-endpoint",
              flowsnakeconfig.maddog_endpoint,
              "--kubeconfig",
              if flowsnakeconfig.is_minikube then "/fake/kubernetes/kubeconfig" else "/kubeconfig",
              "--client-cert",
              if flowsnakeconfig.is_minikube then "/maddog-onebox/client_chain.pem" else "/etc/pki_service/root/madkubtokenserver/certificates/madkubtokenserver.pem",
              "--client-key",
              if flowsnakeconfig.is_minikube then "/maddog-onebox/client-key.pem" else "/etc/pki_service/root/madkubtokenserver/keys/madkubtokenserver-key.pem",
              "--maddog-server-ca",
              if flowsnakeconfig.is_minikube then "/maddog-onebox/ca/security-ca.pem" else "/etc/pki_service/ca/security-ca.pem",
              "--cert-folder",
              "/certs/",
              "--token-folder",
              "/tokens/",
              "--service-hostname",
              if flowsnakeconfig.is_minikube then "madkubserver" else "$(MADKUBSERVER_SERVICE_HOST)",
              "--kingdom",
              kingdom,
              "--estate",
              estate,
            ] +
            (if utils.is_public_cloud(configs.kingdom) then ["--token-ip-use-host-ip"] else []) +
            (if !flowsnakeconfig.is_minikube then [
              "--funnel-endpoint",
              flowsnakeconfig.funnel_endpoint,
            ] else [
              "--log-level",
              "7",
            ]) +
            (if old_062_image then [] else ["--retry-max-elapsed-time", "20s"]),
            image: flowsnake_images.madkub,
            name: "madkubserver",
            ports: [
              {
                containerPort: if flowsnakeconfig.is_minikube then 32007 else 3000,
              },
            ],
            volumeMounts: [
              {
                mountPath: if flowsnakeconfig.is_minikube then "/fake/kubernetes" else "/kubeconfig",
                name: "kubeconfig",
              },
              {
                mountPath: "/certs",
                name: "datacerts",
              },
              {
                mountPath: "/tokens",
                name: "tokens",
              },
            ] +
            (
              if flowsnakeconfig.is_minikube then [
                {
                  mountPath: "/maddog-onebox",
                  name: "maddog-onebox-certs",
                },
            ] else
            [
                {
                  mountPath: "/etc/pki_service/",
                  name: "pki",
                },
            ]
            ),
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
              flowsnakeconfig.maddog_endpoint,
              "--maddog-server-ca",
              if flowsnakeconfig.is_minikube then "/maddog-onebox/ca/security-ca.pem" else "/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca",
              if flowsnakeconfig.is_minikube then "/maddog-onebox/ca/ca.pem" else "/maddog-certs/ca/cacerts.pem",
              "--token-folder",
              "/tokens/",
              "--refresher",
              "--refresher-token-grace-period",
              "30s",
              "--kingdom",
              kingdom,
              "--cert-folders",
              "madkubInternalCert:/certs/",
            ] +
            (if old_062_image then [
            ] else [
              "--ca-folder",
              if flowsnakeconfig.is_minikube then "/maddog-onebox/ca" else "/maddog-certs/ca",
            ]) +
            (if !flowsnakeconfig.is_minikube then [
              "--funnel-endpoint",
              flowsnakeconfig.funnel_endpoint,
            ] else [
              "--log-level",
              "7",
            ]),
            image: flowsnake_images.madkub,
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
            (if flowsnakeconfig.is_minikube then [
                {
                  mountPath: "/maddog-onebox",
                  name: "maddog-onebox-certs",
                },
            ] else [
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
        volumes: [
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
        ] +
        (
          if flowsnakeconfig.is_minikube then [
            {
              name: "kubeconfig",
              configMap: {
                name: "minikube-empty-kubeconfig",
              },
            },
            {
              name: "maddog-onebox-certs",
              hostPath: {
                path: "/tmp/sc_repo",
              },
            },
          ] else [
            {
              name: "kubeconfig",
              hostPath: {
                path: "/etc/kubernetes/kubeconfig",
              },
            },
            {
              name: "pki",
              hostPath: {
                path: "/etc/pki_service",
              },
            },
          ]
        ),
      },
    },
  },
}
