local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local auto_deployer = import "auto_deployer.jsonnet";
if !auto_deployer.auto_deployer_enabled then
"SKIP"
else
{
  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  metadata: {
    labels: {
      name: "samcontrol-deployer",
    },
    name: "samcontrol-deployer",
    namespace: "sam-system",
  },
  spec: {
    replicas: 1,
    template: {
      metadata: {
        labels: {
          apptype: "control",
          name: "samcontrol-deployer",
        },
      },
      spec: {
        containers: [
          {
            command: [
              "/sam/samcontrol-deployer",
              "--config=/config/samcontroldeployer.json",
              "--hostsConfigFile=/sfdchosts/hosts.json",
            ],
            env: [
              {
                name: "KUBECONFIG",
                value: "/kubeconfig/kubeconfig-platform",
              },
            ],
            image: flowsnakeimage.deployer,
            livenessProbe: {
              httpGet: {
                path: "/",
                port: 9099,
              },
              initialDelaySeconds: 2,
              periodSeconds: 10,
              timeoutSeconds: 10,
            },
            name: "samcontrol-deployer",
            volumeMounts: [
              {
                mountPath: "/sfdchosts",
                name: "sfdchosts",
              },
              {
                mountPath: "/etc/pki_service",
                name: "maddog-certs",
              },
              {
                mountPath: "/data/certs",
                name: "certs",
              },
              {
                mountPath: "/kubeconfig",
                name: "kubeconfig",
              },
              {
                mountPath: "/config",
                name: "config",
              },
            ],
          },
        ],
        hostNetwork: true,
        volumes: [
          {
            configMap: {
              name: "sfdchosts",
            },
            name: "sfdchosts",
          },
          {
            hostPath: {
              path: "/etc/pki_service",
            },
            name: "maddog-certs",
          },
          {
            hostPath: {
              path: "/data/certs",
            },
            name: "certs",
          },
          {
            hostPath: {
              path: "/etc/kubernetes",
            },
            name: "kubeconfig",
          },
          {
            configMap: {
              name: "samcontrol-deployer",
            },
            name: "config",
          },
        ],
      },
    },
  },
}
