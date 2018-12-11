local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };

configs.deploymentBase("service-mesh") {
  metadata+: {
    name: "sherpa-injector-deployment",
    namespace: "service-mesh",
    labels: {
      app: "sherpa-injector",
    },
  },
  spec+: {
    replicas: 1,
    template: {
      metadata: {
        labels: {
          app: "sherpa-injector",
          "sherpa-injector.service-mesh/inject": "disabled",
        },
        annotations: {
          "scheduler.alpha.kubernetes.io/critical-pod": "",
          "madkub.sam.sfdc.net/allcerts":
          std.manifestJsonEx(
            {
              certreqs:
                [
                  {
                    "cert-type": "server",
                    kingdom: configs.kingdom,
                    name: "cert1",
                    role: "sherpa-injector.service-mesh",
                    san: [
                      "sherpa-injector",
                      "sherpa-injector.service-mesh",
                      "sherpa-injector.service-mesh.svc",
                      "sherpa-injector.service-mesh.svc.%s" % configs.dnsdomain,
                    ],
                  },
                ],
            }, " "
          ),
        },
      },
      spec: configs.specWithKubeConfigAndMadDog {
        containers: [
          configs.containerWithKubeConfigAndMadDog {
            name: "sherpa-injector",
            image: "sfci/servicelibs/sherpa-injector:b61859372336343d3f26fabe0f35af5faa7b6225",
            imagePullPolicy: "IfNotPresent",
            args: [
              "--port=443",
              "--cert=/server-certificates/cert.pem",
              "--key=/server-certificates/key.pem",
              "--template=test-container.yaml.template",
              "--image=sfci/servicelibs/sherpa-envoy:1.0.4",
              "--log-level=debug",
            ],
            volumeMounts+: [
              {
                name: "cert1",
                mountPath: "/cert1",
              },
            ],
            ports: [
              {
                containerPort: 443,
              },
            ],
            livenessProbe: {
              exec: {
                command: [
                  "/bin/true",
                ],
              },
              initialDelaySeconds: 4,
              periodSeconds: 4,
            },
            readinessProbe: {
              exec: {
                command: [
                  "/bin/true",
                ],
              },
              initialDelaySeconds: 4,
              periodSeconds: 4,
            },
            resources: {},
          },
          {
            image: "" + samimages.madkub + "",
            args: [
              "/sam/madkub-client",
              "--madkub-endpoint=https://10.254.208.254:32007",  // Check madkubserver-service.jsonnet for why IP
              "--maddog-endpoint=" + configs.maddogEndpoint + "",
              "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
              "--cert-folders=cert1:/cert1/",
              "--token-folder=/tokens/",
              "--requested-cert-type=client",
              "--ca-folder=/maddog-certs/ca",
              "--refresher",
              "--run-init-for-refresher-mode",
            ],
            name: "madkub-refresher",
            imagePullPolicy: "IfNotPresent",
            volumeMounts: [
              {
                mountPath: "/cert1",
                name: "cert1",
              },
              {
                mountPath: "/maddog-certs/",
                name: "maddog-certs",
              },
              {
                mountPath: "/tokens",
                name: "tokens",
              },
            ],
            env: [
              {
                name: "MADKUB_NODENAME",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "spec.nodeName", apiVersion: "v1" },
                  },
              },
              {
                name: "MADKUB_NAME",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "metadata.name", apiVersion: "v1" },
                  },
              },
              {
                name: "MADKUB_NAMESPACE",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "metadata.namespace", apiVersion: "v1" },
                  },
              },
            ],
          },
        ],
        # In PRD only kubeapi (master) nodes get cluster-admin permission
        # In production, SAM control estate nodes get cluster-admin permission
        nodeSelector: {} +
          if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then {
              master: "true",
          } else {
              pool: configs.estate,
          },
        volumes+: [
          {
            emptyDir: {
              medium: "Memory",
            },
            name: "cert1",
          },
          {
            emptyDir: {
              medium: "Memory",
            },
            name: "tokens",
          },
        ],
        initContainers+: [
          {
            image: "" + samimages.madkub + "",
            args: [
              "/sam/madkub-client",
              "--madkub-endpoint=https://10.254.208.254:32007",  // Check madkubserver-service.jsonnet for why IP
              "--maddog-endpoint=" + configs.maddogEndpoint + "",
              "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
              "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
              '--cert-folders=cert1:/cert1/',
              "--token-folder=/tokens/",
              "--requested-cert-type=client",
              "--ca-folder=/maddog-certs/ca",
            ],
            name: "madkub-init",
            imagePullPolicy: "IfNotPresent",
            volumeMounts: [
              {
                mountPath: "/cert1",
                name: "cert1",
              },
              {
                mountPath: "/maddog-certs/",
                name: "maddog-certs",
              },
              {
                mountPath: "/tokens",
                name: "tokens",
              },
            ],
            env: [
              {
                name: "MADKUB_NODENAME",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "spec.nodeName", apiVersion: "v1" },
                  },
              },
              {
                name: "MADKUB_NAME",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "metadata.name", apiVersion: "v1" },
                  },
              },
              {
                name: "MADKUB_NAMESPACE",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "metadata.namespace", apiVersion: "v1" },
                  },
              },
            ],
          },
        ],
      },
    },
  },
}
