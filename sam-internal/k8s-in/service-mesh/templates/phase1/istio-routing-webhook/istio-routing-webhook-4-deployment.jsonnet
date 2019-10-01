local configs = import "config.jsonnet";
local madkub = (import "service-mesh/istio-madkub-config.jsonnet") + { templateFilename:: std.thisFile };
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
configs.deploymentBase("service-mesh") {
  local serverCertSans = [
    "istio-routing-webhook",
    "istio-routing-webhook.mesh-control-plane",
    "istio-routing-webhook.mesh-control-plane.svc",
    "istio-routing-webhook.mesh-control-plane.svc.%s" % configs.dnsdomain,
  ],
  local serverCertConfig = madkub.serverCertConfig("server-cert", "/server-cert", "istio-routing-webhook", "mesh-control-plane", serverCertSans),
  local clientCertConfig = madkub.clientCertConfig("client-cert", "/client-cert", "istio-routing-webhook", "mesh-control-plane"),
  local certConfigs = [serverCertConfig, clientCertConfig],

  metadata+: {
    name: "istio-routing-webhook",
    namespace: "mesh-control-plane",
  },
  spec+: {
    replicas: 3,
    selector: {
      matchLabels: {
        app: "istio-routing-webhook",
        name: "istio-routing-webhook",
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
          "sidecar.istio.io/inject": "false",
          "scheduler.alpha.kubernetes.io/critical-pod": "",
        },
        labels: {
          app: "istio-routing-webhook",
          // This name label is required for SAM's pod.* metrics to properly work: https://git.soma.salesforce.com/sam/sam/blob/master/pkg/watchdog/internal/checkers/kuberesourceschecker/internal/pod/podhealthchecker.go#L203
          name: "istio-routing-webhook",
          cluster: mcpIstioConfig.istioEstate,
        },
      },
      spec: configs.specWithMadDog {
        serviceAccountName: "istio-routing-webhook-service-account",
        containers: [
          configs.containerWithMadDog {
            name: "istio-routing-webhook",
            image: mcpIstioConfig.routingWebhookImage,
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
              mcpIstioConfig.funnelEndpoint,
            ],
            env: [
              {
                name: "SETTINGS_SUPERPOD",
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
          {
            args: [
              "proxy",
              "sidecar",
              "--domain",
              "$(POD_NAMESPACE).svc.cluster.local",
              "--log_output_level",
              "default:info",
              "--configPath",
              "/etc/istio/proxy",
              "--binaryPath",
              "/usr/local/bin/envoy",
              "--serviceCluster",
              "istio-routing-webhook.$(POD_NAMESPACE)",
              "--drainDuration",
              "45s",
              "--parentShutdownDuration",
              "1m0s",
              "--discoveryAddress",
              "istio-pilot.mesh-control-plane:15010",
              "--zipkinAddress",
              "zipkin.service-mesh:9411",
              "--proxyLogLevel=info",
              "--dnsRefreshRate",
              "300s",
              "--connectTimeout",
              "10s",
              "--envoyMetricsService",
              '{"address":"switchboard.service-mesh:15001","tls_settings":{"mode":2,"client_certificate":"/client-certs/client/certificates/client.pem","private_key":"/client-certs/client/keys/client-key.pem","ca_certificates":"/client-certs/ca.pem"},"tcp_keepalive":{"probes":3,"time":{"seconds":10},"interval":{"seconds":10}}}',
              "--proxyAdminPort",
              "15373",
              "--concurrency",
              "2",
              "--controlPlaneAuthPolicy",
              "NONE",
              "--statusPort",
              "15020",
            ],
            env: [
              {
                name: "POD_NAME",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.name",
                  },
                },
              },
              {
                name: "POD_NAMESPACE",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.namespace",
                  },
                },
              },
              {
                name: "INSTANCE_IP",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "status.podIP",
                  },
                },
              },
              {
                name: "ISTIO_META_POD_NAME",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.name",
                  },
                },
              },
              {
                name: "ISTIO_META_CONFIG_NAMESPACE",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.namespace",
                  },
                },
              },
              {
                name: "ISTIO_META_INTERCEPTION_MODE",
                value: "REDIRECT",
              },
              {
                name: "ISTIO_META_hostname",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.name",
                  },
                },
              },
              {
                name: "ISTIO_META_namespace",
                valueFrom: {
                  fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.namespace",
                  },
                },
              },
              {
                name: "ISTIO_METAJSON_METRICS_INCLUSIONS",
                value: "{\"sidecar.istio.io/statsInclusionPrefixes\": \"access_log_file,cluster,cluster_manager,control_plane,http,http2,http_mixer_filter,listener,listener_manager,redis,runtime,server,stats,tcp,tcp_mixer_filter,tracing\"}",
              },
              {
                name: "ISTIO_METAJSON_LABELS",
                value: "{\"settings_path\": \"-.-." + configs.kingdom + ".-.istio-routing-webhook\", \"superpod\":" + "\"" + mcpIstioConfig.superpod + "\"}",
              },
              {
                name: "ISTIO_META_TLS_CLIENT_CERT_CHAIN",
                value: "/client-certs/client/certificates/client.pem",
              },
              {
                name: "ISTIO_META_TLS_CLIENT_KEY",
                value: "/client-certs/client/keys/client-key.pem",
              },
              {
                name: "ISTIO_META_TLS_CLIENT_ROOT_CERT",
                value: "/client-certs/ca.pem",
              },
              {
                name: "ISTIO_META_TLS_SERVER_CERT_CHAIN",
                value: "/server-certs/server/certificates/server.pem",
              },
              {
                name: "ISTIO_META_TLS_SERVER_KEY",
                value: "/server-certs/server/keys/server-key.pem",
              },
              {
                name: "ISTIO_META_TLS_SERVER_ROOT_CERT",
                value: "/server-certs/ca.pem",
              },
              {
                name: "ISTIO_META_kubernetes_cluster_name",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "metadata.labels['cluster']",
                  },
                },
              },

            ],
            image: mcpIstioConfig.proxyImage,
            imagePullPolicy: "IfNotPresent",
            name: "istio-proxy",
            ports: [
              {
                containerPort: 15090,
                name: "http-envoy-prom",
                protocol: "TCP",
              },
            ],
            readinessProbe: {
              failureThreshold: 30,
              httpGet: {
                path: "/healthz/ready",
                port: 15020,
                scheme: "HTTP",
              },
              initialDelaySeconds: 1,
              periodSeconds: 2,
              successThreshold: 1,
              timeoutSeconds: 1,
            },
            resources: {
              limits: {
                cpu: "2",
                memory: "1Gi",
              },
              requests: {
                cpu: "100m",
                memory: "128Mi",
              },
            },
            securityContext: {
              readOnlyRootFilesystem: true,
              runAsUser: 7447,
            },
            terminationMessagePath: "/dev/termination-log",
            terminationMessagePolicy: "File",
            volumeMounts: [
              {
                mountPath: "/etc/istio/proxy",
                name: "istio-envoy",
              },
              {
                mountPath: "/client-certs",
                name: "client-cert",
              },
              {
                mountPath: "/server-certs",
                name: "server-cert",
              },
            ],
          },
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
              chmod 775 -R /client-cert && chown -R 7447:7447 /client-cert
|||,
            ],
            securityContext: {
              runAsNonRoot: false,
              runAsUser: 0,
            },
            volumeMounts+: madkub.madkubSamCertVolumeMounts(certConfigs),
          },
          {
            args: [
              "-p",
              "15002",
              "-z",
              "15006",
              "-u",
              "7447",
              "-m",
              "REDIRECT",
              "-i",
              "127.1.2.3/32",
              "-x",
              "",
              "-b",
              "",
              "-d",
              "15020,10443",
            ],
            image: mcpIstioConfig.proxyInitImage,
            imagePullPolicy: "IfNotPresent",
            name: "istio-init",
            resources: {
              limits: {
                cpu: "100m",
                memory: "50Mi",
              },
              requests: {
                cpu: "10m",
                memory: "10Mi",
              },
            },
            securityContext: {
              capabilities: {
                add: [
                  "NET_ADMIN",
                ],
              },
              runAsNonRoot: false,
              runAsUser: 0,
            },
            terminationMessagePath: "/dev/termination-log",
            terminationMessagePolicy: "File",
          },
        ],
        volumes+: madkub.madkubSamCertVolumes(certConfigs) + madkub.madkubSamMadkubVolumes() + mcpIstioConfig.istioEnvoyVolumes(),
      },
    },
  },
}
else "SKIP"
