local configs = import "config.jsonnet";
local istioConfigs = (import "service-mesh/istio-config.jsonnet") + { templateFilename:: std.thisFile };
local istioImages = (import "service-mesh/istio-images.jsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "service-mesh/istio-mesh-webhook/istio-mesh-webhook-madkub.jsonnet") + { templateFilename:: std.thisFile };
local samImages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };

{
  local serverCertSans = [
    "istio-ingressgateway",
    "istio-ingressgateway.mesh-control-plane",
    "istio-ingressgateway.mesh-control-plane.svc",
    "istio-ingressgateway.mesh-control-plane.svc.%s" % configs.dnsdomain,
  ],
  local clientCertConfig = madkub.clientCertConfig("tls-client-cert", "/client-cert", "istio-ingressgateway", "mesh-control-plane"),
  local serverCertConfig = madkub.serverCertConfig("tls-server-cert", "/server-cert", "istio-ingressgateway", "mesh-control-plane", serverCertSans),
  local certConfigs = [clientCertConfig, serverCertConfig],

  apiVersion: 'extensions/v1beta1',
  kind: 'Deployment',
  metadata: {
    name: 'istio-ingressgateway',
    namespace: 'mesh-control-plane',
    labels: {
      chart: 'gateways-1.0.2',
      release: 'istio',
      app: 'istio-ingressgateway',
      istio: 'ingressgateway',
    },
  },
  spec: {
    replicas: 1,
    template: {
      metadata: {
        labels: {
          app: 'istio-ingressgateway',
          istio: 'ingressgateway',
        },
        annotations: {
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
          'sidecar.istio.io/inject': 'false',
          'scheduler.alpha.kubernetes.io/critical-pod': '',
        },
      },
      spec: configs.specWithMadDog {
        containers: [
          configs.containerWithMadDog {
            name: 'istio-proxy',
            image: istioImages.proxy,
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 80,
              },
              {
                containerPort: 443,
              },
              {
                containerPort: 32400,
              },
              {
                containerPort: 15011,
              },
              {
                containerPort: 8060,
              },
              {
                containerPort: 853,
              },
              {
                containerPort: 15030,
              },
              {
                containerPort: 15031,
              },
              {
                containerPort: 15090,
                protocol: 'TCP',
                name: 'http-envoy-prom',
              },
            ],
            args: [
              'proxy',
              'router',
              '-v',
              '2',
              '--discoveryRefreshDelay',
              '1s',
              '--drainDuration',
              '45s',
              '--parentShutdownDuration',
              '1m0s',
              '--connectTimeout',
              '10s',
              '--serviceCluster',
              'istio-ingressgateway',
              '--zipkinAddress',
              'zipkin.service-mesh:9411',
              '--proxyAdminPort',
              '15000',
              '--controlPlaneAuthPolicy',
              'NONE',
              '--discoveryAddress',
              'istio-pilot:8080',
            ],
            resources: {
              requests: {
                cpu: '10m',
              },
            },
            env: [
              {
                name: 'POD_NAME',
                valueFrom: {
                  fieldRef: {
                    apiVersion: 'v1',
                    fieldPath: 'metadata.name',
                  },
                },
              },
              {
                name: 'POD_NAMESPACE',
                valueFrom: {
                  fieldRef: {
                    apiVersion: 'v1',
                    fieldPath: 'metadata.namespace',
                  },
                },
              },
              {
                name: 'INSTANCE_IP',
                valueFrom: {
                  fieldRef: {
                    apiVersion: 'v1',
                    fieldPath: 'status.podIP',
                  },
                },
              },
              {
                name: 'ISTIO_META_POD_NAME',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'metadata.name',
                  },
                },
              },
            ],
            volumeMounts+: [
              // TODO: Do we need the ingressgateway-certs and ingressgateway-ca-certs?

              {
                name: 'tls-server-cert',
                mountPath: '/etc/certs/root-cert.pem',
                subPath: 'ca.pem',
              },
              {
                name: 'tls-server-cert',
                mountPath: '/etc/certs/cert-chain.pem',
                subPath: 'server/certificates/server.pem',
              },
              {
                name: 'tls-server-cert',
                mountPath: '/etc/certs/key.pem',
                subPath: 'server/keys/server-key.pem',
              },

              {
                name: 'tls-client-cert',
                mountPath: '/etc/certs/client.pem',
                subPath: 'client/certificates/client.pem',
              },
              {
                name: 'tls-client-cert',
                mountPath: '/etc/certs/client-key.pem',
                subPath: 'client/keys/client-key.pem',
              },
            ] + madkub.madkubSamCertVolumeMounts(certConfigs),
          },
          madkub.madkubRefreshContainer(certConfigs),
        ],
        initContainers: [
          madkub.madkubInitContainer(certConfigs),
          {
            image: samImages.permissionInitContainer,
            name: "permissionsetterinitcontainer",
            imagePullPolicy: "Always",
            command: [
              "bash",
              "-c",
|||
              set -ex
              chmod 775 -R /client-cert && chown -R 7447:7447 /client-cert
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
        nodeSelector: {
          pool: istioConfigs.istioEstate,
        },
      },
    },
  },
}
