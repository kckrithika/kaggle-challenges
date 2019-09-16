local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnake_config = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

if flowsnake_config.madkub_enabled then
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
    replicas: if flowsnake_config.is_minikube then 1 else 3,
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
        containers: [
          {
            args: [
              "/sam/madkub-server",
              "--listen",
              "0.0.0.0:32007",
              "-d",
              "--maddog-endpoint",
              flowsnake_config.maddog_endpoint,
              "--kubeconfig",
              if flowsnake_config.is_minikube then "/fake/kubernetes/kubeconfig" else "/kubeconfig",
              "--client-cert",
              if flowsnake_config.is_minikube then "/maddog-onebox/client_chain.pem" else "/etc/pki_service/root/madkubtokenserver/certificates/madkubtokenserver.pem",
              "--client-key",
              if flowsnake_config.is_minikube then "/maddog-onebox/client-key.pem" else "/etc/pki_service/root/madkubtokenserver/keys/madkubtokenserver-key.pem",
              "--maddog-server-ca",
              if flowsnake_config.is_minikube then "/maddog-onebox/ca/security-ca.pem" else "/etc/pki_service/ca/security-ca.pem",
              "--cert-folder",
              "/certs/",
              "--token-folder",
              "/tokens/",
              "--service-hostname",
              if flowsnake_config.is_minikube then "madkubserver" else "$(MADKUBSERVER_SERVICE_HOST)",
              "--kingdom",
              kingdom,
              "--estate",
              estate,
            ] +
            (if utils.is_public_cloud(configs.kingdom) then ["--token-ip-use-host-ip"] else []) +
            (if !flowsnake_config.is_minikube then [
              "--funnel-endpoint",
              flowsnake_config.funnel_endpoint,
            ] else [
              "--log-level",
              "7",
            ]) +
            ["--retry-max-elapsed-time", "30s"],
            # In PCL, Madkub server needs to use its host IP for token IP to get token for itself for bootstrapping.
            [if utils.is_public_cloud(configs.kingdom) then "env"]: [
              {
                name: "TOKEN_SERVER_IP",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "status.hostIP",
                  },
                },
              },
            ],
            image: flowsnake_images.madkub,
            name: "madkubserver",
            ports: [
              {
                containerPort: if flowsnake_config.is_minikube then 32007 else 3000,
              },
            ],
            volumeMounts: [
              {
                mountPath: if flowsnake_config.is_minikube then "/fake/kubernetes" else "/kubeconfig",
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
              if flowsnake_config.is_minikube then [
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
              flowsnake_config.maddog_endpoint,
              "--maddog-server-ca",
              if flowsnake_config.is_minikube then "/maddog-onebox/ca/security-ca.pem" else "/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca",
              if flowsnake_config.is_minikube then "/maddog-onebox/ca/ca.pem" else "/maddog-certs/ca/cacerts.pem",
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
            [
              "--ca-folder",
              if flowsnake_config.is_minikube then "/maddog-onebox/ca" else "/maddog-certs/ca",
            ] +
            (if !flowsnake_config.is_minikube then [
              "--funnel-endpoint",
              flowsnake_config.funnel_endpoint,
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
            (if flowsnake_config.is_minikube then [
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
          if flowsnake_config.is_minikube then [
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
    strategy: {
        type: "RollingUpdate",
        rollingUpdate: {
            maxUnavailable: 1,
            maxSurge: 1,
        },
    },
  },
} else "SKIP"
