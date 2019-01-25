local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local versions = import "service-mesh/sherpa-injector/versions.jsonnet";

configs.deploymentBase("service-mesh") {
  metadata+: {
    name: "sherpa-injector",
    namespace: "service-mesh",
    labels: {
      app: "sherpa-injector",
    },
  },
  spec+: {
    replicas: 3,
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
                    role: "sherpa-injector",
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
          {
            name: "sherpa-injector",
            image: versions.injectorImage,
            imagePullPolicy: "IfNotPresent",
            args: [
              "--port=7443",  // can't use 443 here because of the permissions
              "--cert=/server-certificates/server/certificates/server.pem",
              "--key=/server-certificates/server/keys/server-key.pem",
              "--template=sherpa-container.yaml.template",
              "--image=%s" % versions.sherpaImage,
              "--log-level=debug",
            ],
            volumeMounts+: [
              {
                name: "cert1",
                mountPath: "/server-certificates",
              },
            ],
            ports: [
              {
                containerPort: 7443,
              },
            ],
            livenessProbe: {
              exec: {
                command: [
                  "./is-alive.sh",
                  "7443",
                  "/server-certificates/server/certificates/server.pem",
                  "/server-certificates/server/keys/server-key.pem",
                ],
              },
              initialDelaySeconds: 2,
              periodSeconds: 3,
            },
            readinessProbe: {
              exec: {
                command: [
                  "./is-ready.sh",
                  "7443",
                  "/server-certificates/server/certificates/server.pem",
                  "/server-certificates/server/keys/server-key.pem",
                ],
              },
              initialDelaySeconds: 4,
              periodSeconds: 3,
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
              "--requested-cert-type=server",
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
              "--requested-cert-type=server",
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
{
  command: [
        "bash",
        "-c",
        "set -ex\nchmod 775 -R /cert1 && chown -R 7447:7447 /cert1\n",
    ],
        image: "%s/docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673" % configs.registry,
        imagePullPolicy: "IfNotPresent",
        name: "permissionsetterinitcontainer",
        securityContext: {
            runAsNonRoot: false,
            runAsUser: 0,
          },
        volumeMounts: [
          {
            mountPath: "/cert1",
            name: "cert1",
          },
        ],

},


        ],
      },
    },
  },
}
