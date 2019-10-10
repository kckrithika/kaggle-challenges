local configs = import "config.jsonnet";
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");
local madkub = (import "service-mesh/istio-madkub-config.jsonnet") + { templateFilename:: std.thisFile };
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };

if (istioPhases.phaseNum == 3) then
configs.deploymentBase("service-mesh") {

  local serverCertSans = [
    "route-update-service",
    "route-update-service.service-mesh",
    # SAM internal pipeline is generating SAN as service-mesh.route-update-service.sam.sfdc-role. So adding this explicitly.
    "route-update-service.service-mesh.sfdc-role",
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
    selector: {
      matchLabels: {
          app: "route-update-service",
      },
    },
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
          settings_path: "mesh.-." + configs.kingdom + ".-." + "route-update-service",
          sam_function: "route-update-service",
          cluster: mcpIstioConfig.istioEstate,
        },
      },
      spec: configs.specWithMadDog {
        serviceAccountName: "route-update-service-service-account",
        containers: [
          configs.containerWithMadDog {
            name: "route-update-service",
            image: mcpIstioConfig.routeUpdateSvcImage,
            imagePullPolicy: "IfNotPresent",
            args: [
              "-p",
              "7443",
              "--funnel-address",
              mcpIstioConfig.funnelEndpoint,
            ],
            env: [
              {
                name: "ESTATE",
                value: mcpIstioConfig.istioEstate,
              },
              {
                name: "SETTINGS_SUPERPOD",
                value: mcpIstioConfig.superpod,
              },
              {
                name: "SETTINGS_PATH",
                value: "mesh.-." + configs.kingdom + ".-." + "route-update-service",
              },
              {
                name: "FAKE_RESTART_VAR",
                value: "2",
              },
            ],
            ports: [
              {
                containerPort: 7443,
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
            resources: {
              requests: {
                cpu: "100m",
                memory: "128Mi",
              },
              limits: {
                cpu: "1000m",
                memory: "256Mi",
              },
            },
          } + configs.ipAddressResourceRequest,
          madkub.madkubRefreshContainer(certConfigs),
        ],
        nodeSelector: {
          pool: mcpIstioConfig.istioEstate,
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
              chmod 775 -R /tls-client-cert && chown -R 7447:7447 /tls-client-cert
              chmod 775 -R /tls-server-cert && chown -R 7447:7447 /tls-server-cert
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
      },
    },
  },
}
else "SKIP"
