local configs = import "config.jsonnet";
local madkub = (import "service-mesh/istio-madkub-config.jsonnet") + { templateFilename:: std.thisFile };
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");

configs.deploymentBase("service-mesh") {
  local serverCertSans = [
    "istio-routing-webhook",
    "istio-routing-webhook.mesh-control-plane",
    "istio-routing-webhook.mesh-control-plane.svc",
    "istio-routing-webhook.mesh-control-plane.svc.%s" % configs.dnsdomain,
  ],
  local serverCertConfig = madkub.serverCertConfig("server-cert", "/server-cert", "istio-routing-webhook", "mesh-control-plane", serverCertSans),
  local certConfigs = [serverCertConfig],

  metadata+: {
    name: "istio-routing-webhook",
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
          app: "istio-routing-webhook",
          // This name label is required for SAM's pod.* metrics to properly work: https://git.soma.salesforce.com/sam/sam/blob/master/pkg/watchdog/internal/checkers/kuberesourceschecker/internal/pod/podhealthchecker.go#L203
          name: "istio-routing-webhook",
        },
      },
      spec: configs.specWithMadDog {
        serviceAccountName: "istio-routing-webhook-service-account",
        containers: [
          configs.containerWithMadDog {
            name: "istio-routing-webhook",
            image: "ops0-artifactrepo2-0-prd.data.sfdc.net/sfci/servicemesh/istio-routing-webhook:c970d64cfb4967722f9139ff2bea5c9c13905373",
            imagePullPolicy: "IfNotPresent",
            args: [
              "server",
              "--cert",
              "/server-cert/server/certificates/server.pem",
              "--key",
              "/server-cert/server/keys/server-key.pem",
              "--port",
              "10443",
              "--funnel-address",
              mcpIstioConfig.funnelHost + ":" + mcpIstioConfig.funnelPort,
            ],
            env: [
              {
                name: "SUPERPOD",
                value: mcpIstioConfig.superpod,
              },
              {
                name: "SETTINGS_PATH",
                value: "-.-." + configs.kingdom + ".-." + "istio-routing-webhook",
              },
              {
                name: "ESTATE",
                value: configs.estate,
              },
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
            volumeMounts+: madkub.madkubSamCertVolumeMounts(certConfigs),
          },
          madkub.madkubRefreshContainer(certConfigs),
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
      },
    },
  },
}
