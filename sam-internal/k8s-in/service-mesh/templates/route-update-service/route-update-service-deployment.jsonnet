# this deployment specifies certs even though we don't use them yet.
# This is for 2 reasons:
# 1. When removed SAM complained about a missing token volume (perhaps related to the service account?) :
#       "MountVolume.SetUp failed for volume "route-update-service-service-account-token-bmbgz" : secrets "route-update-service-service-account-token-bmbgz" is forbidden: User "test1shared0-samminionatlasdir2-1-prd.eng.sfdc.net" cannot get secrets in the namespace "service-mesh"
# 2. Eventually we will want certs for envoy on this app so we're leaving them here for now.
local configs = import "config.jsonnet";
local mcpIstioConfig = import "service-mesh/istio-config.jsonnet";
local madkub = (import "service-mesh/istio-madkub-config.jsonnet") + { templateFilename:: std.thisFile };
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };

configs.deploymentBase("service-mesh") {

  local serverCertSans = [
    "route-update-service",
    "route-update-service.service-mesh",
    "route-update-service.service-mesh.svc",
    "route-update-service.service-mesh.svc.%s" % configs.dnsdomain,
  ],

  local clientCertConfig = madkub.clientCertConfig("tls-client-cert", "/tls-client-cert", "route-update-service", "service-mesh"),
  local serverCertConfig = madkub.serverCertConfig("tls-server-cert", "/tls-server-cert", "route-update-service", "service-mesh", serverCertSans),

  local certConfigs = [clientCertConfig, serverCertConfig],

  metadata+: {
    name: "route-update-service",
    namespace: "service-mesh",
    annotations: {
      "sidecar.istio.io/inject": "true",
      "routing.mesh.sfdc.net/enabled": "true",
    },
  },
  spec+: {
    progressDeadlineSeconds: 600,
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
          "sidecar.istio.io/inject": "true",
           "routing.mesh.sfdc.net/enabled": "true",
        },
        labels: {
          app: "route-update-service",
          settings_path: "test.-.prd.-.route-update-service",
          superpod: "NONE",
        }
      },
      spec: configs.specWithMadDog {
        serviceAccountName: "route-update-service-service-account",
        containers: [
          configs.containerWithMadDog {
            name: "route-update-service",
            image: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/servicemesh/route-update-service:b817daada3298bf9b1c337fb383f67949615b342",
            imagePullPolicy: "IfNotPresent",
            args: [],
            env: [
              {
                name: "ESTATE",
                value: mcpIstioConfig.istioEstate,
              },
            ],
            ports: [
              {
                containerPort: 7020,
                name: "grpc-svc",
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
          pool: mcpIstioConfig.istioEstate,
        },
        volumes+: madkub.madkubSamCertVolumes(certConfigs) + madkub.madkubSamMadkubVolumes(),
      }
    }
  },
}

