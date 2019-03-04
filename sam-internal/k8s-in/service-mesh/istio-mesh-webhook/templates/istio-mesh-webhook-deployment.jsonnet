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
    replicas: 3,
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
          "sidecar.istio.io/inject": "false",
          "scheduler.alpha.kubernetes.io/critical-pod": "",
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
            image: "ops0-artifactrepo2-0-prd.data.sfdc.net/sfci/servicemesh/servicemesh/istio-routing-webhook:5983bee629e29fd72e89457b3da4da219234d466",
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
          master: "true",
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
}
