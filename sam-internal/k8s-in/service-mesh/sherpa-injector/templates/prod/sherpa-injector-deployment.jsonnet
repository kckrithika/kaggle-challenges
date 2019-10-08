local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local versions = import "service-mesh/sherpa-injector/versions.jsonnet";
local sherpa_utils = import "service-mesh/sherpa-injector/sherpa_utils.jsonnet";
local maddogInit = import "service-mesh/sherpa-injector/maddog/_init-cert-container.jsonnet";
local maddogPermissions = import "service-mesh/sherpa-injector/maddog/_init-permissions-container.jsonnet";
local maddogRefresher = import "service-mesh/sherpa-injector/maddog/_cert-refresher-container.jsonnet";
local utils = import "util_functions.jsonnet";
local funnelEndpointHost = std.split(configs.funnelVIP, ":")[0];
local funnelEndpointPort = std.split(configs.funnelVIP, ":")[1];

if sherpa_utils.is_sherpa_injector_prod_cluster(configs.estate) then
configs.deploymentBase("service-mesh") {
  metadata+: {
    name: "sherpa-injector",
    namespace: versions.injectorNamespace,
    labels: {
      app: "sherpa-injector",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
  },
  spec+: {
    replicas: if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || utils.is_pcn(configs.kingdom) then 1 else 3,
    template: {
      metadata: {
        labels: {
          app: "sherpa-injector",
          name: "sherpa-injector",
          "sherpa-injector.service-mesh/inject": "disabled",
        },
        annotations: {
          "sherpa-injector.service-mesh/inject": "disabled",
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
                      "sherpa-injector.%s" % versions.injectorNamespace,
                      "sherpa-injector.%s.svc" % versions.injectorNamespace,
                      "sherpa-injector.%s.svc.cluster.local" % versions.injectorNamespace,
                      "sherpa-injector.%s.svc.%s" % [
                        versions.injectorNamespace,
                        (if configs.estate == "gsf-core-devmvp-sam2-sam" then "gsf-core-devmvp-sam2-samtest.mvp.sam.sfdc.net" else configs.dnsdomain),
                      ],
                    ],
                  },
                  {
                    "cert-type": "client",
                    kingdom: configs.kingdom,
                    name: "cert2",
                    role: "sherpa-injector",
                    san: [
                      "sherpa-injector",
                      "sherpa-injector.%s" % versions.injectorNamespace,
                      "sherpa-injector.%s.svc" % versions.injectorNamespace,
                      "sherpa-injector.%s.svc.cluster.local" % versions.injectorNamespace,
                      "sherpa-injector.%s.svc.%s" % [
                        versions.injectorNamespace,
                        (if configs.estate == "gsf-core-devmvp-sam2-sam" then "gsf-core-devmvp-sam2-samtest.mvp.sam.sfdc.net" else configs.dnsdomain),
                      ],
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
            name: "injector",
            image: if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then versions.canaryInjectorImage else versions.injectorImage,
            imagePullPolicy: "IfNotPresent",
            terminationMessagePolicy: "FallbackToLogsOnError",
            args: [
              "--template=%s" % "/config-data/sherpa-container.yaml.template",  // This is the template that we have stored in a ConfigMap in k8s
              "--image=%s" % versions.sherpaImage,
              "--log-level=debug",
              "--port=17442",  // Similar to Sherpa (h1 TLS IN), but +10000, since we don't want to clash with sherpa ports
              "--cert=/server-certs/server/certificates/server.pem",
              "--key=/server-certs/server/keys/server-key.pem",
            ] +
            if std.length(versions.canarySherpaImage) > 0 then [
              "--canary-image=%s" % versions.canarySherpaImage,
            ],
            env+: [
              {
                name: "SFDC_ENVIRONMENT",
                value: "prod",
              },
              {
                name: "SETTINGS_SERVICENAME",
                value: "sherpa-injector",
              },
              {
                name: "FUNCTION_NAMESPACE",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "metadata.namespace", apiVersion: "v1" },
                  },
              },
              {
                name: "FUNCTION_INSTANCE_NAME",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "metadata.name", apiVersion: "v1" },
                  },
              },
              {
                name: "FUNCTION_INSTANCE_IP",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "status.podIP", apiVersion: "v1" },
                  },
              },
              {
                name: "FUNCTION",
                value: "sherpa-injector",
              },
              {
                name: "KINGDOM",
                value: configs.kingdom,
              },
              {
                name: "ESTATE",
                value: configs.estate,
              },
              {
                name: "SUPERPOD",
                value: "-",
              },
              {
                name: "SETTINGS_SUPERPOD",
                value: "-",
              },
              {
                name: "SETTINGS_PATH",
                value: "prod.-." + configs.kingdom + ".-.sherpa-injector",
              },
              {
                name: "SFDC_SETTINGS_PATH",
                value: "prod.-." + configs.kingdom + ".-.sherpa-injector",
              },
              {
                name: "SFDC_METRICS_SERVICE_HOST",
                // use `value: funnelEndpointHost,` if direct link to ajna is needed
                value: "ajnafunneldirecttls.funnel.localhost.mesh.force.com",
              },
              {
                name: "SFDC_METRICS_SERVICE_PORT",
                // use `value: funnelEndpointPort,` if direct link to ajna is needed
                value: "5442",
              },
              {
                name: "FAKE_REDEPLOY_VAR",
                value: "2",
              },
            ],
            volumeMounts+: [
              {
                name: "cert1",
                mountPath: "/server-certs",
              },
              {
                name: "cert2",
                mountPath: "/client-certs",
              },
              {
                name: "sherpa-injector-configs-data-volume",
                mountPath: "/config-data",
              },
            ],
            ports+: [
              {
                containerPort: 17442,
              },
            ],
            livenessProbe: {
              exec: {
                command: [
                  "./is-alive.sh",
                  "17442",
                  // Pass the certificates folder for the liveness probe to use TLS
                  "/client-certs/client/certificates/client.pem",
                  "/client-certs/client/keys/client-key.pem",
                ],
              },
              initialDelaySeconds: 2,
              periodSeconds: 3,
            },
            readinessProbe: {
              exec: {
                command: [
                  "./is-ready.sh",
                  "17442",
                  // Pass certificates for the readiness probe to use with TLS
                  "/client-certs/client/certificates/client.pem",
                  "/client-certs/client/keys/client-key.pem",
                ],
              },
              initialDelaySeconds: 4,
              periodSeconds: 3,
            },
            resources: {},
          } + configs.ipAddressResourceRequest,
          maddogRefresher.madkubRefresherContainer,
          {
            name: "sherpa",
            image: versions.sherpaImage,
            imagePullPolicy: "IfNotPresent",
            terminationMessagePolicy: "FallbackToLogsOnError",
            args+: [] +
            if utils.is_pcn(configs.kingdom) then ["--switchboard=switchboard.service-mesh.svc:15001"] else [],
            env+: [
              {
                name: "SFDC_ENVIRONMENT",
                value: "mesh",
              },
              {
                name: "SETTINGS_SERVICENAME",
                value: "sherpa-injector",
              },
              {
                name: "FUNCTION_NAMESPACE",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "metadata.namespace", apiVersion: "v1" },
                  },
              },
              {
                name: "FUNCTION_INSTANCE_NAME",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "metadata.name", apiVersion: "v1" },
                  },
              },
              {
                name: "FUNCTION_INSTANCE_IP",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "status.podIP", apiVersion: "v1" },
                  },
              },
              {
                name: "FUNCTION",
                value: "sherpa-injector",
              },
              {
                name: "KINGDOM",
                value: configs.kingdom,
              },
              {
                name: "ESTATE",
                value: configs.estate,
              },
              {
                name: "SUPERPOD",
                value: "-",
              },
              {
                name: "SETTINGS_SUPERPOD",
                value: "-",
              },
              {
                name: "SETTINGS_PATH",
                value: "prod.-." + configs.kingdom + ".-.sherpa-injector",
              },
              {
                name: "SFDC_SETTINGS_PATH",
                value: "prod.-." + configs.kingdom + ".-.sherpa-injector",
              },
              {
                name: "SFDC_METRICS_SERVICE_HOST",
                value: funnelEndpointHost,
              },
              {
                name: "SFDC_METRICS_SERVICE_PORT",
                value: funnelEndpointPort,
              },
            ],

            volumeMounts+: [
              {
                name: "cert1",
                mountPath: "/server-certs",
              },
              {
                name: "cert2",
                mountPath: "/client-certs",
              },
            ],
            ports: [
              // We don't expose any IN ports here, because Sherpa will only be used for Egress
              {
                // admin
                containerPort: 15373,
              },
            ],
            livenessProbe: {
              exec: {
                command: [
                  "./bin/is-alive",
                ],
              },
              initialDelaySeconds: 5,
              periodSeconds: 5,
            },
            readinessProbe: {
              exec: {
                command: [
                  "./bin/is-ready",
                ],
              },
              initialDelaySeconds: 4,
              periodSeconds: 5,
            },
            resources: {
              limits: {
                cpu: "1",
                memory: "1Gi",
              },
              requests: {
                cpu: "1",
                memory: "1Gi",
              },
            },
        },
        ],
        
        nodeSelector: { pool: configs.estate, },
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
            name: "cert2",
          },
          {
            emptyDir: {
              medium: "Memory",
            },
            name: "tokens",
          },
          {
            configMap: {
              name: "sherpa-injector-configs-data",
            },
            name: "sherpa-injector-configs-data-volume",
          },
        ] +
        if utils.is_pcn(configs.kingdom) then
        [
          {
            hostPath: {
              path: "/etc/pki_service",
            },
            name: "maddog-certs",
          },
        ]
        else [],
        initContainers+: [
          maddogInit.madkubInitContainer,
          maddogPermissions.permissionSetterInitContainer,
        ],
      },
    },
  },
} else "SKIP"
