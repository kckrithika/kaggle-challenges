local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };


if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    kind: "Deployment",
    apiVersion: "extensions/v1beta1",
    metadata: {
        name: "sam-api-proxy",
        namespace: "sam-system",
    },
    spec: {
        replicas: 2,
        template: {
          metadata: {
            labels: {
              apptype: "control",
              name: "sam-api-proxy",
            },
          },
          spec: {
            containers: [
              {
                command: [
                  "/sam/sam-api-proxy",
                  "--config=/config/sam-api-proxy.json",
                  "--v=10",
                  "--ciNamespaceConfigFile=/ci/ci-namespaces.json",
                  "-alsologtostderr",
                ] +
                (if configs.estate == "prd-samdev" then ["-namespaceWhiteListRegex=e2e-crd-*"] else []),
                image: samimages.hypersam,
                name: "sam-api-proxy",
                volumeMounts: [
                  {
                    mountPath: "/config",
                    name: "config",
                    readOnly: true,
                  },
                  {
                    mountPath: "/etc/pki_service",
                    name: "maddog-certs",
                  },
                  {
                    mountPath: "/ci",
                    name: "ci-namespaces",
                  },
                ],
              },
            ],
            hostNetwork: true,
            nodeSelector: {
              master: "true",
            },
            volumes: [
              {
                configMap: {
                  name: "sam-api-proxy",
                },
                name: "config",
              },
              {
                hostPath: {
                  path: "/etc/pki_service",
                },
                name: "maddog-certs",
              },
              {
                configMap: {
                  name: "ci-namespaces",
                },
                name: "ci-namespaces",
              },
            ],
          },
        },
      },
} else "SKIP"
