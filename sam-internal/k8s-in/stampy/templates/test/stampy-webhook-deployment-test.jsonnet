local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local versions = import "stampy/versions.jsonnet";
local stampy_utils = import "stampy/stampy_utils.jsonnet";
local maddogInit = import "stampy/maddog/_init-cert-container.jsonnet";
local maddogPermissions = import "stampy/maddog/_init-permissions-container.jsonnet";
local maddogRefresher = import "stampy/maddog/_cert-refresher-container.jsonnet";
local utils = import "util_functions.jsonnet";
local funnelEndpointHost = std.split(configs.funnelVIP, ":")[0];
local funnelEndpointPort = std.split(configs.funnelVIP, ":")[1];

if stampy_utils.is_stampy_webhook_test_cluster(configs.estate) then
configs.deploymentBase("stampy") {
  metadata+: {
    name: "stampy-webhook-deployment",
    namespace: versions.injectorNamespace,
    labels: {
      app: "stampy-webhook",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
  },
  spec+: {
    replicas: if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || utils.is_pcn(configs.kingdom) then 1 else 3,
    template: {
      metadata: {
        labels: {
          app: "stampy-webhook",
          name: "stampy-webhook",
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
                    role: "stampy-webhook",
                    san: [
                      "stampy-webhook",
                      "stampy-webhook.%s" % versions.injectorNamespace,
                      "stampy-webhook.%s.svc" % versions.injectorNamespace,
                      "stampy-webhook.%s.svc.cluster.local" % versions.injectorNamespace,
                      "stampy-webhook.%s.svc.%s" % [
                        versions.injectorNamespace,
                        (if configs.estate == "gsf-core-devmvp-sam2-sam" then "gsf-core-devmvp-sam2-samtest.mvp.sam.sfdc.net" else configs.dnsdomain),
                      ],
                    ],
                  },
                  {
                    "cert-type": "client",
                    kingdom: configs.kingdom,
                    name: "cert2",
                    role: "stampy-webhook",
                    san: [
                      "stampy-webhook",
                      "stampy-webhook.%s" % versions.injectorNamespace,
                      "stampy-webhook.%s.svc" % versions.injectorNamespace,
                      "stampy-webhook.%s.svc.cluster.local" % versions.injectorNamespace,
                      "stampy-webhook.%s.svc.%s" % [
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
            image: versions.stampyWebhookImage,
            imagePullPolicy: "Always",
            terminationMessagePolicy: "FallbackToLogsOnError",
            args: [
              "-log-level=debug",
              "-tls-port=17772",
              "-http-port=17773",
              "-cert-file-path=/server-certs/server/certificates/server.pem",
              "-key-file-path=/server-certs/server/keys/server-key.pem"
            ],
            env+: [
              {
                name: "SFDC_ENVIRONMENT",
                value: "stampy",
              },
              {
                name: "SETTINGS_SERVICENAME",
                value: "stampy-webhook",
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
                value: "stampy-webhook",
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
                value: "stampy.-." + configs.kingdom + ".-.stampy-webhook",
              },
              {
                name: "SFDC_SETTINGS_PATH",
                value: "stampy.-." + configs.kingdom + ".-.stampy-webhook",
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
                value: "1",
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
        ],
        # In PRD only kubeapi (master) nodes get cluster-admin permission
        # In production, SAM control estate nodes get cluster-admin permission
        nodeSelector: {} +
          if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
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
              name: "stampy-webhook-configs-data",
            },
            name: "stampy-webhook-configs-data-volume",
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
