local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
{
  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  metadata: {
    labels: {
        service: "madkubserver",
    },
    name: "madkubserver",
    namespace: "flowsnake",
  },
  spec: {
    replicas: if flowsnakeconfig.is_minikube then 1 else 3,
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
              if flowsnakeconfig.is_minikube then "https://maddog-onebox:8443" else "https://all.pkicontroller.pki.blank." + kingdom + ".prod.non-estates.sfdcsd.net:8443",
              "--kubeconfig",
              if flowsnakeconfig.is_minikube then "/fake/kubernetes/kubeconfig" else "/kubeconfig",
              "--client-cert",
              if flowsnakeconfig.is_minikube then "/sc/client_chain.pem" else "/etc/pki_service/root/madkubtokenserver/certificates/madkubtokenserver.pem",
              "--client-key",
              if flowsnakeconfig.is_minikube then "/sc/client-key.pem" else "/etc/pki_service/root/madkubtokenserver/keys/madkubtokenserver-key.pem",
              "--maddog-server-ca",
              if flowsnakeconfig.is_minikube then "/sc/ca/security-ca.pem" else "/etc/pki_service/ca/security-ca.pem",
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
            (if !flowsnakeconfig.is_minikube then [
              "--funnel-endpoint",
              flowsnakeconfig.funnel_endpoint,
            ] else []),
            image: flowsnakeimage.madkub,
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
            (if flowsnakeconfig.is_minikube then [
                {
                  mountPath: "/sc",
                  name: "maddog-onebox-claim",
                },
            ] else [
                {
                  mountPath: "/data/certs",
                  name: "kubeconfig-certs",
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
              if flowsnakeconfig.is_minikube then "https://maddog-onebox:8443" else "https://all.pkicontroller.pki.blank." + kingdom + ".prod.non-estates.sfdcsd.net:8443",
              "--maddog-server-ca",
              if flowsnakeconfig.is_minikube then "/sc/ca/security-ca.pem" else "/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca",
              if flowsnakeconfig.is_minikube then "/sc/ca/ca.pem" else "/maddog-certs/ca/cacerts.pem",
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
            (if !flowsnakeconfig.is_minikube then [
              "--funnel-endpoint",
              flowsnakeconfig.funnel_endpoint,
            ] else []),
            image: flowsnakeimage.madkub,
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
                  mountPath: "/sc",
                  name: "maddog-onebox-claim",
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
        (if flowsnakeconfig.is_minikube then [
            {
              name: "kubeconfig",
              configMap: {
                name: "minikube-empty-kubeconfig",
              },
            },
            {
              name: "maddog-onebox-claim",
              persistentVolumeClaim: {
                claimName: "maddog-onebox-claim",
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
        ]),
      },
    },
  },
}
