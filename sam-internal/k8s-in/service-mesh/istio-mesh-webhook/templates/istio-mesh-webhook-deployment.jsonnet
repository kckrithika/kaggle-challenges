local configs = import "config.jsonnet";
local madkub = (import "service-mesh/istio-mesh-webhook/istio-mesh-webhook-madkub.jsonnet") + { templateFilename:: std.thisFile };
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };

configs.deploymentBase("service-mesh") {
  local serverCertSans = [
    "istio-mesh-webhook",
    "istio-mesh-webhook.mesh-control-plane",
    "istio-mesh-webhook.mesh-control-plane.svc",
    "istio-mesh-webhook.mesh-control-plane.svc.%s" % configs.dnsdomain,
  ],
  local serverCertConfig = madkub.serverCertConfig("server-cert", "/server-cert", "istio-mesh-webhook", "mesh-control-plane", serverCertSans),
  local certConfigs = [serverCertConfig],

  metadata+: {
    name: "istio-mesh-webhook",
    namespace: "mesh-control-plane",
  },
  spec+: {
    replicas: 1,
    template: {
      metadata: {
        annotations+: {
          "madkub.sam.sfdc.net/allcerts":
          std.manifestJsonEx(
            {
              certreqs:
                [
                  certReq
                  for certReq in madkub.madkubSamCertsAnnotation(certConfigs).certreqs
                ],
            }, " "
          ),
        },
        labels: {
          app: "istio-mesh-webhook",
        }
      },
      spec: configs.specWithMadDog {
        serviceAccountName: "istio-mesh-webhook-service-account",
        containers: [
          configs.containerWithMadDog {
            name: "istio-mesh-webhook",
            image: "ops0-artifactrepo2-0-prd.data.sfdc.net/sfci/servicemesh/istio-mesh-webhook:0c50ffd9a17d2b17d2fca7b5b7891f46fd49b6bb",
            imagePullPolicy: "IfNotPresent",
            args: [
              "server",
              "--cert",
              "/server-cert/server/certificates/server.pem",
              "--key",
              "/server-cert/server/keys/server-key.pem",
              "--port",
              "10443",
            ],
            env+: $.kubernetesServiceOverride(),
            ports: [
              {
                containerPort: 10443,
              },
            ],
            readinessProbe: {
              exec: {
                command: [
                  "/bin/true",
                ],
              },
              initialDelaySeconds: 5,
              periodSeconds: 30,
              timeoutSeconds: 5,
            },
            volumeMounts+: madkub.madkubSamCertVolumeMounts(certConfigs)
          },
          madkub.madkubRefreshContainer(certConfigs)
        ],
        nodeSelector: {
          pool: configs.estate,
        },
        initContainers: [
          madkub.madkubInitContainer(certConfigs),
          {
            image: samimages.permissionInitContainer,
            name: "permissionsetterinitcontainer",
            imagePullPolicy: "Always",
            command: [
              "bash",
              "-c",
|||
              set -ex
              chmod 775 -R /server-cert && chown -R 7447:7447 /server-cert
|||,
            ],
            securityContext: {
              runAsNonRoot: false,
              runAsUser: 0,
            },
            volumeMounts+: madkub.madkubSamCertVolumeMounts(certConfigs),
          },
        ],
        volumes+: madkub.madkubSamCertVolumes(certConfigs) + madkub.madkubSamMadkubVolumes(),
      }
    }
  },

  kubernetesServiceOverride()::
    if configs.estate == "prd-samtest" then [
      {
        name: "KUBERNETES_SERVICE_HOST",
        value: "shared0-samtestkubeapi2-1-prd.eng.sfdc.net",
      },
      {
        name: "KUBERNETES_SERVICE_PORT",
        value: "6443",
      },
    ] else if configs.estate == "prd-sam" then [
      {
        name: "KUBERNETES_SERVICE_HOST",
        value: "shared0-samkubeapi1-1-prd.eng.sfdc.net",
      },
      {
        name: "KUBERNETES_SERVICE_PORT",
        value: "6443",
      },
    ] else {},
}
