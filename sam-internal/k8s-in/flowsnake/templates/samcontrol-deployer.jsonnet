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
            ],
            env: [
              {
                name: "KUBECONFIG",
                value: "/kubeconfig/kubeconfig-platform",
              },
            ],
            image: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:sam-0001501-6ebd0f4f",
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
