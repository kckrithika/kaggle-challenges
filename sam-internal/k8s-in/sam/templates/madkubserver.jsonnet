local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.estate == "prd-samtest" then {
  kind: "Deployment",
  metadata: {
    name: "madkubserver",
    namespace: "sam-system"
  },
  spec: {
    replicas: 3,
    template: {
      metadata: {
        labels: {
          service: "madkubserver"
        }
      },
      spec: {
        nodeSelector: {
          "kubernetes.io/hostname": "shared0-samtestkubeapi1-1-prd.eng.sfdc.net",
        },
        containers: [
          {
            args: [
              "/sam/server",
              "--listen", "0.0.0.0:32007",
              "-d",
              "--maddog-endpoint", "https://all.pkicontroller.pki.blank.prd.prod.non-estates.sfdcsd.net:8443",
              "--kubeconfig", "/kubeconfig",
              "--client-cert", "/maddog-certs/root/madkubtokenserver/certificates/client.pem",
              "--client-key", "/maddog-certs/root/madkubtokenserver/keys/client-key.pem",
              "--maddog-server-ca", "/maddog-certs/ca/security-ca.pem",
              "--cert-folder", "/certs/",
              "--token-folder", "/tokens/",
              "--service-hostname", "$(MADKUBSERVER_SERVICE_HOST)"
            ],
            image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/cdebains/madkub:test-54795af-20170830-225547",
            name: "madkubserver",
            ports: [
              {
                containerPort: 3000
              }
            ],
            volumeMounts: [
              {
                mountPath: "/kubeconfig",
                name: "kubeconfig"
              },
              {
                mountPath: "/data/certs",
                name: "kubeconfig-certs"
              },
              {
                mountPath: "/certs",
                name: "datacerts"
              },
              {
                mountPath: "/tokens",
                name: "tokens"
              },
              {
                mountPath: "/maddog-certs/",
                name: "maddog-certs"
              }
            ],
            readinessProbe: {
              tcpSocket: {
                port: 32007
              },
              initialDelaySeconds: 5,
              periodSeconds: 20
            },
            livenessProbe: {
              tcpSocket: {
                port: 32007
              },
              initialDelaySeconds: 20,
              periodSeconds: 20
            }
          },
          {
            name: "madkub-refresher",
            args: [
              "/sam/client",
              "--madkub-endpoint", "",
              "--maddog-endpoint", "https://all.pkicontroller.pki.blank.prd.prod.non-estates.sfdcsd.net:8443",
              "--maddog-server-ca", "/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca", "/maddog-certs/ca/cacerts.pem",
              "--cert-folder", "/certs/",
              "--token-folder", "/tokens/",
              "--refresher",
              "--refresher-token-grace-period", "30s"
            ],
            image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/cdebains/madkub:test-54795af-20170830-225547",
            resources: {
            },
            volumeMounts: [
              {
                mountPath: "/certs",
                name: "datacerts"
              },
              {
                mountPath: "/tokens",
                name: "tokens"
              },
              {
                mountPath: "/maddog-certs/",
                name: "maddog-certs"
              }
            ],
            env: [
              {
                name: "MADKUB_NODENAME",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "spec.nodeName"
                  }
                }
              },
              {
                name: "MADKUB_NAME",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "metadata.name"
                  }
                }
              },
              {
                name: "MADKUB_NAMESPACE",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "metadata.namespace"
                  }
                }
              }
            ]
          }
        ],
        restartPolicy: "Always",
        volumes: [
          {
            name: "kubeconfig",
            hostPath: {
              path: "/etc/kubernetes/kubeconfig"
            }
          },
          {
            name: "kubeconfig-certs",
            hostPath: {
              path: "/data/certs"
            }
          },
          {
            name: "maddog-certs",
            hostPath: {
              path: "/etc/pki_service"
            }
          },
          {
            name: "datacerts",
            emptyDir: {
              medium: "Memory"
            }
          },
          {
            name: "tokens",
            emptyDir: {
              medium: "Memory"
            }
          }
        ]
      }
    }
  }
} else "SKIP"